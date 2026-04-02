import SwiftUI

struct AppTheme {
    struct Colors {
        static let paperCanvas = Color(hexString: "DFD9CF")
        static let paperBackground = Color(hexString: "F2EFE9")
        static let waxRed = Color(hexString: "AA3A3A")
        static let stampLight = Color(hexString: "FDFCF9")
        static let postmarkInk = Color.black.opacity(0.3)
        static let classicBlue = Color(hexString: "1A2B3C")
    }
}

// MARK: - 艺术滤镜：双色调 (DuoTone / Gradient Map)
extension View {
    func duoToneEffect(dark: Color = Color(hexString: "1A2B3C"), light: Color = Color(hexString: "F2EFE9")) -> some View {
        self
            .grayscale(1.0)
            .contrast(1.2)
            .overlay(dark.blendMode(.multiply))
            .overlay(light.blendMode(.screen).opacity(0.2))
    }
}

// MARK: - 精确锯齿几何形状 (Postage Perforations)
// MARK: - 精确锯齿几何形状 (Postage Perforations)
// (Moved to Components/Shapes/StampBorder.swift)


// MARK: - 复古纸张纹理
// MARK: - 复古纸张纹理 (优化版本：消除缩放闪烁)
// MARK: - 精品复古纸张纹理 (有机纤维效果)
struct VintagePaperTexture: View {
    var body: some View {
        Canvas { context, size in
            // 1. 底层微粒感
            for i in 0..<1500 {
                let x = CGFloat((Int(size.width) ^ (i * 12345)) % Int(size.width))
                let y = CGFloat((Int(size.height) ^ (i * 67890)) % Int(size.height))
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 0.6, height: 0.6)), with: .color(.black.opacity(0.04)))
            }
            
            // 2. 有机纸张纤维 (散乱的线条)
            for i in 0..<100 {
                let x = CGFloat((Int(size.width) ^ (i * 98765)) % Int(size.width))
                let y = CGFloat((Int(size.height) ^ (i * 54321)) % Int(size.height))
                let length = CGFloat.random(in: 4...12)
                let angle = CGFloat.random(in: 0...Double.pi * 2)
                
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(
                    x: x + cos(angle) * length,
                    y: y + sin(angle) * length
                ))
                
                context.stroke(path, with: .color(Color(hexString: "A59E92").opacity(0.2)), lineWidth: 0.3)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 高级视觉增强
extension View {
    // 模拟真实光效：当物体倾斜时边缘产生的微光
    func premiumStampLighting() -> some View {
        self.overlay(
            StampShape()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .clear, .black.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .stampMask()
        )
    }
    
    // 增加内部投影，使海报看起来像是“嵌”在邮票里的
    func internalInnerShadow() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                .blur(radius: 0.5)
                .offset(x: 0, y: 0.5)
                .mask(RoundedRectangle(cornerRadius: 2))
        )
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
