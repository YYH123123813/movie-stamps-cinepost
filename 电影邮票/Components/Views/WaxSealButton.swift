import SwiftUI

struct WaxSealButton: View {
    var action: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                // High-Fidelity 3D Asset
                Image("wax_seal_upload_button_v2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85) // Slightly larger for impact
                    .shadow(color: .black.opacity(0.4), radius: 8, y: 5) // Deep shadow for float effect
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
