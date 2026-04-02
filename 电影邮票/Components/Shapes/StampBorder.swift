import SwiftUI

// 优化后的邮票形状，孔稍微大一点，间距稍微密一点，更像真正的邮票
struct StampShape: Shape {
    let holeRadius: CGFloat = 3.5
    let spacing: CGFloat = 13.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start with the main rectangle
        path.addRect(rect)
        
        // Add circles along the edges. 
        // With Even-Odd fill rule, these will become holes where they overlap the rect.
        let width = rect.width
        let height = rect.height
        
        // horizontal edges
        let hCount = Int(width / spacing)
        let hOffset = (width - CGFloat(hCount) * spacing) / 2
        
        for i in 0...hCount {
            let x = hOffset + CGFloat(i) * spacing
            // Top
            path.addEllipse(in: CGRect(x: x - holeRadius, y: -holeRadius, width: holeRadius*2, height: holeRadius*2))
            // Bottom
            path.addEllipse(in: CGRect(x: x - holeRadius, y: height - holeRadius, width: holeRadius*2, height: holeRadius*2))
        }
        
        // vertical edges
        let vCount = Int(height / spacing)
        let vOffset = (height - CGFloat(vCount) * spacing) / 2
        
        for i in 0...vCount {
            let y = vOffset + CGFloat(i) * spacing
            // Left
            path.addEllipse(in: CGRect(x: -holeRadius, y: y - holeRadius, width: holeRadius*2, height: holeRadius*2))
            // Right
            path.addEllipse(in: CGRect(x: width - holeRadius, y: y - holeRadius, width: holeRadius*2, height: holeRadius*2))
        }
        
        return path
    }
}

// Helper to apply the mask with even-odd fill rule
extension View {
    func stampMask() -> some View {
        self.mask(
            StampShape()
                .fill(style: FillStyle(eoFill: true))
        )
        .clipped()
    }
}
