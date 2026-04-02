import SwiftUI

struct MovieStampView: View {
    let movie: MovieItem
    var isResizing: Bool = false
    
    var body: some View {
        ZStack {
            // MARK: - 1. STAMP BASE
            Rectangle()
                .fill(AppTheme.Colors.stampLight)
                .stampMask()
            
            // MARK: - 2. CONTENT LAYER
            VStack(spacing: 0) {
                ZStack {
                    if let data = movie.posterImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            // 性能优化：缩放过程中降低插值质量，静止时恢复最高画质
                            .interpolation(isResizing ? .low : .high) 
                            .antialiased(!isResizing)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 180)
                            .clipped()
                            .overlay(Color.black.opacity(0.02)) 
                            .mask(RoundedRectangle(cornerRadius: 1))
                            .internalInnerShadow() 
                    } else {
                        // High-end Typography Fallback
                        fallbackView
                    }
                    
                    // MARK: - 3. MODERN OVERLAY
                    overlayInfo
                }
                .compositingGroup() // Isolates content layer rendering
                .padding(15)
            }
            .frame(width: 170, height: 230)
            
            // Texture & Rim Light
            VintagePaperTexture()
                .opacity(0.15)
                .blendMode(.multiply)
                .stampMask()
            
            Color.clear.premiumStampLighting()
            
            // Decorative Postmark
            postmarkView
        }
        .frame(width: 170, height: 230)
        // 核心性能优化：强制 Metal 渲染，合并复杂图层
        .drawingGroup() 
    }
    
    private var fallbackView: some View {
        ZStack {
            Rectangle().fill(AppTheme.Colors.waxRed.opacity(0.03))
            VStack(spacing: 12) {
                Text(movie.title.prefix(1).uppercased())
                    .font(.system(size: 72, weight: .black, design: .serif))
                    .foregroundStyle(
                        LinearGradient(colors: [AppTheme.Colors.waxRed.opacity(0.3), AppTheme.Colors.waxRed.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
                Image(systemName: "film.fill").font(.system(size: 14)).foregroundStyle(AppTheme.Colors.waxRed.opacity(0.1))
            }
        }
        .frame(width: 140, height: 180)
    }
    
    private var overlayInfo: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title.uppercased())
                        .font(.system(size: 11, weight: .black, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(movie.watchDate.formatted(.dateTime.year().month().day()))
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Text(String(format: "%.1f", movie.rating))
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.waxRed)
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            )
        }
        .frame(width: 140, height: 180)
    }
    
    private var postmarkView: some View {
        Image(systemName: "seal")
            .font(.system(size: 48))
            .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.06))
            .rotationEffect(.degrees(-20))
            .offset(x: 48, y: 58)
    }
}
