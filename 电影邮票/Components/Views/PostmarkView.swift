import SwiftUI

struct PostmarkView: View {
    let text: String // e.g., "OCT 24" or "WATCHED"
    let date: Date
    
    // Random seed for rotation and ink imperfection
    let rotation: Double = Double.random(in: -15...15)
    let inkOpacity: Double = Double.random(in: 0.7...0.9)
    
    var body: some View {
        ZStack {
            // 1. Outer Circles (Double ring style)
            Circle()
                .strokeBorder(
                    .primary.opacity(inkOpacity * 0.8),
                    style: StrokeStyle(lineWidth: 1.5, dash: [4, 2])
                )
                .frame(width: 80, height: 80)
            
            Circle()
                .strokeBorder(
                    .primary.opacity(inkOpacity * 0.5),
                    lineWidth: 0.5
                )
                .frame(width: 74, height: 74)
            
            // 2. Wavy Lines (The cancellation mark)
            HStack(spacing: 4) {
                ForEach(0..<6) { _ in
                    WaveShape()
                        .stroke(
                            .primary.opacity(inkOpacity * 0.6),
                            style: StrokeStyle(lineWidth: 1, lineCap: .round)
                        )
                        .frame(width: 30, height: 10)
                }
            }
            .offset(x: 20, y: 10) // Offset to look like it continues off text
            .mask(Circle().frame(width: 80, height: 80)) // Clip to circle
            
            // 3. Text Info (Date / Location)
            VStack(spacing: 2) {
                Text(text.uppercased())
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .kerning(1.5)
                
                Text(formatDate(date))
                    .font(.system(size: 9, weight: .bold, design: .serif))
                
                Text("AIR MAIL")
                    .font(.system(size: 7, weight: .medium))
                    .padding(.top, 2)
            }
            .foregroundStyle(.primary.opacity(inkOpacity))
        }
        // Blend Mode: Multiplayer for ink soaking effect
        .blendMode(.multiply)
        .rotationEffect(.degrees(rotation))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd" // Chinese/Scientific standard
        return formatter.string(from: date)
    }
}

// Simple Wave Shape for the cancellation lines
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        path.addCurve(
            to: CGPoint(x: width, y: midHeight),
            control1: CGPoint(x: width * 0.25, y: midHeight - arrowDeepness(rect)),
            control2: CGPoint(x: width * 0.75, y: midHeight + arrowDeepness(rect))
        )
        return path
    }
    
    private func arrowDeepness(_ rect: CGRect) -> CGFloat {
        return rect.height
    }
}

#Preview {
    ZStack {
        Color(red: 0.9, green: 0.88, blue: 0.85).ignoresSafeArea()
        PostmarkView(text: "NEW YORK", date: Date())
    }
}
