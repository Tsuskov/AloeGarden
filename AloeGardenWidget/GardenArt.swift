import SwiftUI

// Minimal copy of the garden artwork the widget needs. Kept self-contained so the
// extension does not depend on the app target. Mirrors the shapes in AloeGardenApp.swift.

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: alpha)
    }
}

let leafGradient = LinearGradient(colors: [Color(hex: 0x5E7350), Color(hex: 0xA9BB86)], startPoint: .bottom, endPoint: .top)
let leafHiGradient = LinearGradient(colors: [Color(hex: 0x7E9466), Color(hex: 0xC8D4AB)], startPoint: .bottom, endPoint: .top)

struct Leaf: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); let w = r.width, h = r.height
        let cx = w / 2, sx = w / 18, sy = h / 100
        p.move(to: CGPoint(x: cx, y: h))
        p.addCurve(to: CGPoint(x: cx, y: 0),
                   control1: CGPoint(x: cx - 8 * sx, y: h - 32 * sy),
                   control2: CGPoint(x: cx - 9 * sx, y: h - 66 * sy))
        p.addCurve(to: CGPoint(x: cx, y: h),
                   control1: CGPoint(x: cx + 9 * sx, y: h - 66 * sy),
                   control2: CGPoint(x: cx + 8 * sx, y: h - 32 * sy))
        p.closeSubpath(); return p
    }
}

struct LeafView: View {
    var length: CGFloat; var width: CGFloat
    var body: some View {
        ZStack {
            Leaf().fill(leafGradient)
            Leaf().scale(x: 0.4, y: 0.9, anchor: .center).fill(leafHiGradient).opacity(0.5)
        }
        .frame(width: width, height: length)
    }
}

struct AloeRosette: View {
    var length: CGFloat = 96
    var leafWidth: CGFloat = 18
    private let leaves: [(Double, CGFloat)] =
        [(-68, 0.70), (-50, 0.80), (-32, 0.90), (-15, 0.97), (0, 1.0),
         (15, 0.97), (32, 0.90), (50, 0.80), (68, 0.70)]
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(0..<leaves.count, id: \.self) { i in
                LeafView(length: length * leaves[i].1, width: leafWidth * leaves[i].1)
                    .rotationEffect(.degrees(leaves[i].0), anchor: .bottom)
            }
        }
        .frame(width: length * 1.8, height: length, alignment: .bottom)
    }
}
