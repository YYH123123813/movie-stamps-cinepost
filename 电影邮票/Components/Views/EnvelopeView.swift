import SwiftUI

struct EnvelopeView: View {
    let month: String
    let movieCount: Int
    @Binding var isOpen: Bool
    
    // Thickness simulation
    private var thickness: CGFloat {
        return min(CGFloat(movieCount) * 1.2, 8.0)
    }
    
    var body: some View {
        ZStack {
            // MARK: Drop Shadow
            Color.black.opacity(0.15)
                .frame(width: 130 + thickness, height: 90 + thickness)
                .blur(radius: 8)
                .offset(x: 0, y: 8 + thickness/2)
            
            // MARK: Main Envelope Body (Back)
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.93, green: 0.91, blue: 0.86))
                    .frame(width: 140, height: 100)
                
                // MARK: Movie Cards Peeking Out (Visual Trick)
                if isOpen {
                    ForEach(0..<min(3, movieCount), id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 120, height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.1)))
                            .offset(y: CGFloat(-20 - (i * 10)))
                            .transition(.move(edge: .bottom))
                    }
                }
            }
            .compositingGroup()
            
            // MARK: The Folded Flap (Triangle)
            flapView
                .frame(height: 60)
            
            // Front Bottom Pocket
            pocketView
                .frame(height: 100)
            
            // Month Label
            if !isOpen {
                monthLabel
            }
        }
        .drawingGroup() // 强制 Metal 渲染复杂信封结构
    }
    
    private var flapView: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 70, y: 55))
                path.addLine(to: CGPoint(x: 140, y: 0))
                path.closeSubpath()
            }
            .fill(Color(red: 0.90, green: 0.88, blue: 0.84))
            .rotation3DEffect(
                .degrees(isOpen ? 180 : 0),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                anchor: .top,
                perspective: 0.8
            )
            .overlay(
                Circle()
                    .fill(AppTheme.Colors.waxRed)
                    .frame(width: 22, height: 22)
                    .offset(x: 70 - 11, y: 55 - 11)
                    .rotation3DEffect(
                        .degrees(isOpen ? 180 : 0),
                        axis: (x: 1.0, y: 0.0, z: 0.0),
                        anchor: .top
                    )
                    .opacity(isOpen ? 0 : 1)
                , alignment: .topLeading
            )
        }
    }
    
    private var pocketView: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 100))
            path.addLine(to: CGPoint(x: 70, y: 50))
            path.addLine(to: CGPoint(x: 140, y: 100))
            path.closeSubpath()
        }
        .fill(Color(red: 0.93, green: 0.91, blue: 0.86).opacity(0.9))
    }
    
    private var monthLabel: some View {
        HStack(spacing: 0) {
            Text(month).font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(Color.black.opacity(0.65))
        .padding(4)
        .background(Color.white.opacity(0.7))
        .rotationEffect(.degrees(-6))
        .offset(x: -30, y: 25)
    }
}

