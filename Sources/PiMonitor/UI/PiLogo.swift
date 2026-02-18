//
//  PiLogo.swift
//  PiIsland
//
//  Pi logo as a SwiftUI Shape
//

import SwiftUI

/// Pi logo shape - a stylized "Pi" mark
struct PiLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Scale to fit the rect (original viewBox is 800x800)
        let scale = min(rect.width, rect.height) / 800
        let offsetX = (rect.width - 800 * scale) / 2
        let offsetY = (rect.height - 800 * scale) / 2
        
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: offsetX + x * scale, y: offsetY + y * scale)
        }
        
        // P shape outer boundary (clockwise)
        path.move(to: point(165.29, 165.29))
        path.addLine(to: point(517.36, 165.29))
        path.addLine(to: point(517.36, 400))
        path.addLine(to: point(400, 400))
        path.addLine(to: point(400, 517.36))
        path.addLine(to: point(282.65, 517.36))
        path.addLine(to: point(282.65, 634.72))
        path.addLine(to: point(165.29, 634.72))
        path.closeSubpath()
        
        // P shape inner hole (counter-clockwise for even-odd fill)
        path.move(to: point(282.65, 282.65))
        path.addLine(to: point(282.65, 400))
        path.addLine(to: point(400, 400))
        path.addLine(to: point(400, 282.65))
        path.closeSubpath()
        
        // i dot
        path.move(to: point(517.36, 400))
        path.addLine(to: point(634.72, 400))
        path.addLine(to: point(634.72, 634.72))
        path.addLine(to: point(517.36, 634.72))
        path.closeSubpath()
        
        return path
    }
}

/// Pi logo view with optional animation
struct PiLogo: View {
    let size: CGFloat
    var isAnimating: Bool = false
    var isPulsing: Bool = false  // For hint state - gentler pulse
    var bounce: Bool = false     // One-time bounce when response is ready
    var color: Color = .white

    @State private var bounceScale: CGFloat = 1.0
    @State private var shimmerPhase: CGFloat = 0.0
    
    var body: some View {
        PiLogoShape()
            .fill(
                // Liquid Shimmer Gradient
                LinearGradient(
                    stops: [
                        .init(color: color.opacity(isAnimating ? 0.9 : 0.6), location: 0),
                        .init(color: color.opacity(isAnimating ? 0.3 : 0.6), location: 0.45), // Highlight
                        .init(color: color.opacity(isAnimating ? 0.9 : 0.6), location: 1)
                    ],
                    startPoint: UnitPoint(x: isAnimating ? shimmerPhase - 1 : 0, y: 0),
                    endPoint: UnitPoint(x: isAnimating ? shimmerPhase : 1, y: 1)
                ),
                style: FillStyle(eoFill: true)
            )
            .frame(width: size, height: size)
            .scaleEffect(effectiveScale * bounceScale)
            .animation(.easeInOut(duration: 0.3), value: isAnimating) // Smooth transition for state changes
            .onChange(of: bounce) { _, shouldBounce in
                if shouldBounce {
                    performBounce()
                }
            }
            .onAppear {
                if isAnimating { startShimmer() }
            }
            .onChange(of: isAnimating) { _, animating in
                if animating {
                    startShimmer()
                } else {
                    stopShimmer()
                }
            }
    }
    
    private func startShimmer() {
        // Reset phase
        shimmerPhase = 0
        // Continuous shimmer loop
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerPhase = 2.0
        }
    }
    
    private func stopShimmer() {
        withAnimation(.easeOut(duration: 0.3)) {
            shimmerPhase = 0
        }
    }

    private var effectiveScale: CGFloat {
        if isAnimating {
            return 1.05 // Subtle breathe
        } else if isPulsing {
            return 1.1
        }
        return 1.0
    }

    private func performBounce() {
        // Quick scale up
        withAnimation(.spring(response: 0.12, dampingFraction: 0.5)) {
            bounceScale = 1.3
        }

        // Scale back down with bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                bounceScale = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PiLogo(size: 64, isAnimating: false)
        PiLogo(size: 64, isAnimating: true)
        PiLogo(size: 32)
        PiLogo(size: 16)
    }
    .padding()
    .background(Color.black)
}
