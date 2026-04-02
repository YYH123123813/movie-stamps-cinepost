import SwiftUI
import SwiftData

struct MovieLetterView: View {
    let movie: MovieItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // MARK: - Stationery Paper Background
            Color(hexString: "FDFCF9") // Cream paper
                .ignoresSafeArea()
                .overlay(StationeryTexture())
            
            ScrollView {
                VStack(spacing: 30) {
                    // MARK: - Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.waxRed)
                                .padding(12)
                                .background(Circle().fill(Color.white).shadow(radius: 2))
                        }
                        Spacer()
                        Text(movie.watchDate.formatted(date: .long, time: .omitted))
                            .font(.custom("Palatino-Italic", size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // MARK: - High-Res Movie Stamp
                    ZStack {
                        if let data = movie.posterImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 280)
                                .clipped()
                                .mask(StampShape().stroke(lineWidth: 12)) // Edge effect
                                .shadow(radius: 10)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 200, height: 280)
                                .overlay(Image(systemName: "film"))
                        }
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Movie Title
                    Text(movie.title)
                        .font(.custom("Palatino-Bold", size: 32))
                        .foregroundStyle(Color.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // MARK: - Companion (同行者)
                    if !movie.companions.isEmpty {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.6))
                            Text("With: \(movie.companions)")
                                .font(.custom("Palatino-Italic", size: 18))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // MARK: - Thoughts (Handwritten Style)
                    VStack(alignment: .leading, spacing: 15) {
                        Image(systemName: "quote.opening")
                            .font(.title)
                            .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.3))
                        
                        Text(movie.review.isEmpty ? "A silent memory..." : movie.review)
                            .font(.custom("AmericanTypewriter", size: 19)) // Better handwritten approximation
                            .foregroundStyle(Color(hexString: "1A2B3C")) // Inky Blue
                            .lineSpacing(8)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Rating
                    RatingStars(rating: movie.rating)
                        .scaleEffect(1.2)
                        .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct StationeryTexture: View {
    var body: some View {
        Canvas { context, size in
            // Subtle horizontal lines
            let step: CGFloat = 35
            for y in stride(from: 100, to: size.height, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: 40, y: y))
                path.addLine(to: CGPoint(x: size.width - 40, y: y))
                context.stroke(path, with: .color(Color.black.opacity(0.04)), lineWidth: 1)
            }
            
            // Vertical margin line
            var verticalPath = Path()
            verticalPath.move(to: CGPoint(x: 60, y: 0))
            verticalPath.addLine(to: CGPoint(x: 60, y: size.height))
            context.stroke(verticalPath, with: .color(AppTheme.Colors.waxRed.opacity(0.1)), lineWidth: 1)
        }
    }
}
