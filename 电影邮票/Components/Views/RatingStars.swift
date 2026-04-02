import SwiftUI

struct RatingStars: View {
    let rating: Double
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(5, Int(rating)), id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.orange)
            }
        }
    }
}
