import SwiftUI

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var rect = rect
            switch edge {
            case .top:
                rect.size.height = width
            case .bottom:
                rect.origin.y = rect.maxY - width
                rect.size.height = width
            case .leading:
                rect.size.width = width
            case .trailing:
                rect.origin.x = rect.maxX - width
                rect.size.width = width
            }
            path.addRect(rect)
        }
        return path
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(
            EdgeBorder(width: width, edges: edges)
                .foregroundColor(color)
        )
    }
}
