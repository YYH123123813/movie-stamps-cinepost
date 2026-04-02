import SwiftUI
import SwiftData

struct MovieStampContainer: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var movie: MovieItem
    
    // Interaction states
    @State private var isFlipped = false
    @State private var isSelected = false
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var showEditSheet = false
    
    // Scale & Physical States
    @State private var liveScale: CGFloat = 1.0
    @State private var liveRotation: Double = 0.0
    @State private var isResizing = false
    @State private var isRotating = false
    @State private var liftScale: CGFloat = 1.0 // 翻转时的“弹起”缩放
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // MARK: - THE UNIFIED STAMP UNIT (整体旋转核心)
            // 关键：不要在这里加 frame，否则旋转时四个角会被剪裁
            ZStack {
                // 背面底层
                StampBackView(movie: movie, 
                    onFlip: { flip() }, 
                    onDelete: { modelContext.delete(movie) },
                    onEdit: { showEditSheet = true }
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                
                // 正面层
                MovieStampView(movie: movie, isResizing: isResizing || isRotating || isDragging)
                    .opacity(isFlipped ? 0 : 1)
            }
            .id(movie.id)
            .rotationEffect(.degrees(liveRotation)) // 让信封边边和内容一起整体旋转
            .rotation3DEffect(Angle(degrees: isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(liftScale) 
            .compositingGroup() // 保证锯齿边缘和光影整体性
            
            // 仅在静止选中时显示精致阴影
            .shadow(
                color: (isResizing || isRotating || isDragging || liftScale > 1.0) ? .clear : .black.opacity(isSelected ? 0.25 : 0.12),
                radius: (isResizing || isRotating || isDragging || liftScale > 1.0) ? 0 : (isSelected ? 15 : 8),
                x: 0, 
                y: (isResizing || isRotating || isDragging || liftScale > 1.0) ? 0 : 4
            )
            
            // Interaction Handles
            if isSelected && !isDragging && !isResizing && !isRotating && liftScale == 1.0 {
                actionOverlay
            }

            // MARK: - UNIVERSAL MANIPULATOR HANDLE (相对于屏幕坐标系，不随邮票旋转)
            if isSelected && !isDragging && !isFlipped && liftScale == 1.0 {
                UniversalHandle(
                    scale: $liveScale,
                    rotation: $liveRotation,
                    isInteracting: Binding(
                        get: { isResizing || isRotating },
                        set: { isResizing = $0; isRotating = $0 }
                    ),
                    onEnd: { finalScale, finalRotation in
                        Task.detached {
                            await MainActor.run {
                                movie.scale = Double(finalScale)
                                movie.rotation = Double(finalRotation)
                                try? modelContext.save()
                            }
                        }
                    }
                )
                .offset(x: 25, y: 25)
                .zIndex(2000)
            }
        }
        // 关键：整体缩放和位移放在最外层，且不再限制 frame
        .scaleEffect(liveScale)
        .offset(dragOffset)
        .zIndex(isSelected || isDragging || isResizing || isRotating || liftScale > 1.0 ? 1000 : 1)
        
        // 极致灵敏曲线
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.82), value: isSelected)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.82), value: isDragging)
        .animation(.interactiveSpring(response: 0.45, dampingFraction: 0.85), value: isFlipped)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: isResizing)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: isRotating)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: liftScale)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.82), value: liveScale)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.82), value: liveRotation)
        
        // GESTURES
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                    isDragging = true
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let finalTranslation = value.translation
                    // 异步保存坐标
                    Task.detached {
                        await MainActor.run {
                            movie.xPosition += finalTranslation.width
                            movie.yPosition += finalTranslation.height
                            dragOffset = .zero
                            isDragging = false
                            isSelected = true 
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                isSelected.toggle()
                if isSelected { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            }
        }
        .onLongPressGesture(minimumDuration: 0.4) {
            flip()
        }
        .onAppear {
            liveScale = min(CGFloat(movie.scale), 5.0)
            liveRotation = movie.rotation
        }
        .onChange(of: movie.scale) { _, newValue in
            if !isResizing {
                withAnimation(.interactiveSpring(response: 0.4)) {
                    liveScale = min(CGFloat(newValue), 5.0)
                }
            }
        }
        .onChange(of: movie.rotation) { _, newValue in
            if !isRotating {
                withAnimation(.interactiveSpring(response: 0.4)) {
                    liveRotation = newValue
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditMovieView(movie: movie)
        }
    }
    
    private var actionOverlay: some View {
        VStack(spacing: 15) {
            ActionButton(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", action: flip)
            ActionButton(icon: "pencil", action: { showEditSheet = true })
        }
        .padding(15)
        .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
    }
    
    private func flip() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        
        // 极高水准的平滑全物理动效：弹起 -> 旋转 -> 落下
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            liftScale = 1.15 // 弹起
            isSelected = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                liftScale = 1.0 // 落下
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.Colors.waxRed)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
        }
    }
}

// ... StampBackView Updated with Images ...
struct StampBackView: View {
    let movie: MovieItem
    var onFlip: () -> Void
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    @ObservedObject var lang = LanguageManager.shared
    
    var body: some View {
        ZStack {
            // Paper base
            Rectangle()
                .fill(AppTheme.Colors.stampLight)
                .stampMask()
            
            VStack(spacing: 0) {
                // Header (Postal Code Style)
                HStack {
                    Text("CINEPOST / ARCHIVE")
                        .font(.custom("AmericanTypewriter-Bold", size: 8))
                        .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.4))
                    Spacer()
                }
                .padding(.top, 25)
                .padding(.horizontal, 25)
                
                // Content ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // 1. Companion Image (The missing 2nd photo!)
                        if let d = movie.companionImageData, let ui = UIImage(data: d) {
                            VStack(spacing: 4) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 80)
                                    .clipped()
                                    .overlay(Rectangle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 1)
                                    .rotationEffect(.degrees(Double.random(in: -2...2))) // 随机小倾斜增加真实感
                                
                                Text(movie.companions.isEmpty ? "Memory Moment" : movie.companions)
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 5)
                            .frame(maxWidth: .infinity)
                        } else if !movie.companions.isEmpty {
                            // Text only fallback for companion
                            HStack(alignment: .top, spacing: 5) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.4))
                                Text(movie.companions)
                                    .font(.system(size: 10, design: .serif))
                            }
                        }
                        
                        // 2. Thoughts
                        VStack(alignment: .leading, spacing: 6) {
                            Text(lang.s("thoughts").uppercased())
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.6))
                            
                            Text(movie.review.isEmpty ? lang.s("no_journal") : movie.review)
                                .font(.system(size: 11, design: .serif))
                                .lineSpacing(4)
                                .foregroundStyle(Color.black.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                }
                
                Spacer()
                
                // Bottom Tools
                HStack(spacing: 30) {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.4))
                    }
                    
                    Button(action: onFlip) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.6))
                    }
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.classicBlue.opacity(0.5))
                    }
                }
                .padding(.bottom, 25)
            }
            
            // Texture
            VintagePaperTexture()
                .opacity(0.1)
                .blendMode(.multiply)
                .stampMask()
        }
        .frame(width: 170, height: 230)
    }
}

struct UniversalHandle: View {
    @Binding var scale: CGFloat
    @Binding var rotation: Double
    @Binding var isInteracting: Bool
    var onEnd: (CGFloat, Double) -> Void
    
    @State private var startScale: CGFloat = 1.0
    @State private var startRotation: Double = 0.0
    
    var body: some View {
        Circle()
            .fill(Color.white)
            // 操控时立即清除按键阴影，杜绝重影
            .shadow(color: isInteracting ? .clear : .black.opacity(0.15), radius: isInteracting ? 0 : 8, x: 1, y: 3)
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(AppTheme.Colors.waxRed)
                    .rotationEffect(.degrees(rotation))
            )
            .background(
                Circle()
                    .stroke(AppTheme.Colors.waxRed.opacity(0.15), lineWidth: 4)
                    .scaleEffect(isInteracting ? 1.5 : 1.0)
                    .opacity(isInteracting ? 0 : 1)
            )
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: isInteracting)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isInteracting {
                            isInteracting = true
                            startScale = scale
                            startRotation = rotation
                        }
                        
                        // 统一计算核心：基于位移的缩放与基于角度的旋转
                        let dist = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        let deltaScale = dist / 160.0
                        let direction: CGFloat = (value.translation.width + value.translation.height) > 0 ? 1 : -1
                        
                        // 1. 无感更新缩放 (保持灵敏)
                        scale = min(max(startScale + (deltaScale * direction), 0.2), 5.0)
                        
                        // 2. 优化：高精度阻尼旋转 (Damped Rotation)
                        // 不再直接使用 atan2 映射，而是使用位移累积驱动，产生“重手感”
                        // 这是一个“刻度盘”逻辑：手指划过的弧长决定旋转弧度
                        let rotationSensitivity: Double = 0.6 // 阻尼系数：越小越沉稳
                        let dragVector = value.translation.width - value.translation.height
                        let dampedRotation = startRotation + (Double(dragVector) * rotationSensitivity)
                        
                        rotation = dampedRotation
                        
                        // 档位感通知 (每 15 度震动)
                        if Int(rotation) % 15 == 0 {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                            isInteracting = false
                        }
                        onEnd(scale, rotation)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            )
    }
}
