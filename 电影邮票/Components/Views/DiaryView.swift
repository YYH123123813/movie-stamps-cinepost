import SwiftUI
import SwiftData

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MovieItem.watchDate, order: .reverse) private var movies: [MovieItem]
    @ObservedObject var lang = LanguageManager.shared
    
    @State private var showAddMovieSheet: Bool = false
    @State private var selectedDockIndex: Int = 0 
    
    // 【画布定位核心变量】
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - 1. THE PAPER CANVAS
            AppTheme.Colors.paperCanvas
                .ignoresSafeArea()
                .overlay(VintagePaperTexture().opacity(0.4).blendMode(.multiply).ignoresSafeArea())
            
            // MARK: - 2. CONTENT AREA
            Group {
                if selectedDockIndex == 0 {
                    MainCanvasComponent(movies: movies, zoomScale: $zoomScale, offset: $offset, lastOffset: $lastOffset)
                } else if selectedDockIndex == 1 {
                    SearchArchiveView(movies: movies)
                } else if selectedDockIndex == 2 {
                    StatsView(movies: movies)
                } else {
                    ProfileView()
                }
            }
            .ignoresSafeArea()
            
            // MARK: - 3. TOP BAR (Recenter)
            if selectedDockIndex == 0 {
                VStack {
                    HStack {
                        Text("CinePost")
                            .font(.system(size: 32, weight: .black, design: .serif))
                            .foregroundStyle(AppTheme.Colors.waxRed)
                        Spacer()
                        Button(action: { locateLatestStamp() }) {
                            Image(systemName: "location.north.circle.fill")
                                .font(.title)
                                .foregroundStyle(AppTheme.Colors.waxRed)
                                .background(Circle().fill(.white))
                        }
                        .shadow(radius: 4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                    Spacer()
                }
            }
            
            // MARK: - 4. FULL DOCK
            bottomDock
        }
        .sheet(isPresented: $showAddMovieSheet) { 
            AddMovieView()
                .environment(\.modelContext, modelContext)
        }
    }
    
    private var bottomDock: some View {
        ZStack(alignment: .bottom) {
            EnvelopeFlapShape()
                .fill(AppTheme.Colors.paperCanvas)
                .frame(height: 120)
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
                .overlay(
                    HStack(spacing: 0) {
                        TabIcon(activeIcon: "book.pages.fill", inactiveIcon: "book.pages", index: 0, selection: $selectedDockIndex)
                        Spacer()
                        TabIcon(activeIcon: "magnifyingglass", inactiveIcon: "magnifyingglass", index: 1, selection: $selectedDockIndex) // 避免使用可能冲突的 .fill
                        Spacer().frame(width: 100)
                        TabIcon(activeIcon: "chart.bar.fill", inactiveIcon: "chart.bar", index: 2, selection: $selectedDockIndex)
                        Spacer()
                        TabIcon(activeIcon: "person.fill", inactiveIcon: "person", index: 3, selection: $selectedDockIndex)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                )
            
            WaxSealButton(action: { showAddMovieSheet = true })
                .frame(width: 80, height: 80)
                .offset(y: -75)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // 【定位逻辑：强制回归中心或最新邮票】
    private func locateLatestStamp() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            zoomScale = 1.0
            if let latest = movies.first {
                // 将最新邮票的位置对准屏幕中心
                // 坐标计算：offset 是相对于画布中心(2000,2000)的偏移
                offset = CGSize(
                    width: -(latest.xPosition - 2000),
                    height: -(latest.yPosition - 2000)
                )
            } else {
                // 如果没邮票，默认回到画布正中心
                offset = .zero
            }
            lastOffset = offset
        }
    }
}

// 辅助组件保持
struct MainCanvasComponent: View {
    let movies: [MovieItem]
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @State private var lastZoomScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景网格绘制
                Canvas { context, size in
                    let step: CGFloat = 80
                    for x in stride(from: 0, to: size.width, by: step) {
                        context.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))}, with: .color(.black.opacity(0.05)), lineWidth: 0.5)
                    }
                    for y in stride(from: 0, to: size.height, by: step) {
                        context.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))}, with: .color(.black.opacity(0.05)), lineWidth: 0.5)
                    }
                }
                .frame(width: 4000, height: 4000)
                .background(AppTheme.Colors.paperCanvas.opacity(0.1))
                
                // 邮票层
                ForEach(movies) { movie in
                    MovieStampContainer(movie: movie)
                        .position(x: movie.xPosition, y: movie.yPosition)
                }
            }
            .frame(width: 4000, height: 4000)
            .scaleEffect(zoomScale)
            .position(
                x: (geo.size.width / 2) + offset.width * zoomScale,
                y: (geo.size.height / 2) + offset.height * zoomScale
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { v in 
                        offset = CGSize(
                            width: lastOffset.width + v.translation.width / zoomScale,
                            height: lastOffset.height + v.translation.height / zoomScale
                        )
                    }
                    .onEnded { _ in lastOffset = offset }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / 1.0
                        let newScale = lastZoomScale * delta
                        zoomScale = min(max(newScale, 0.3), 3.0)
                    }
                    .onEnded { _ in
                        lastZoomScale = zoomScale
                    }
            )
            .onAppear {
                if offset == .zero {
                    locateInitialView()
                }
                lastZoomScale = zoomScale
            }
        }
    }
    
    private func locateInitialView() {
        if let latest = movies.first {
            offset = CGSize(width: -(latest.xPosition - 2000), height: -(latest.yPosition - 2000))
        } else {
            offset = .zero
        }
        lastOffset = offset
    }
}

struct TabIcon: View {
    let activeIcon: String
    let inactiveIcon: String
    let index: Int
    @Binding var selection: Int
    var body: some View {
        Button(action: {
            withAnimation { selection = index }
        }) {
            VStack(spacing: 4) {
                Image(systemName: selection == index ? activeIcon : inactiveIcon)
                    .font(.system(size: 24))
                    .foregroundStyle(selection == index ? AppTheme.Colors.waxRed : Color.black.opacity(0.4))
                
                if selection == index {
                    Circle().fill(AppTheme.Colors.waxRed).frame(width: 4, height: 4)
                } else {
                    Circle().fill(Color.clear).frame(width: 4, height: 4)
                }
            }
            .frame(width: 60, height: 44)
        }
    }
}

struct EnvelopeFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 45))
        path.addLine(to: CGPoint(x: rect.width/2, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 45))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}
