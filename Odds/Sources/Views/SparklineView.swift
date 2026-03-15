import SwiftUI

struct SparklineView: View {
    let data: [Double]
    let trend: PriceTrend

    var body: some View {
        Canvas { context, size in
            guard data.count >= 2 else { return }

            let minVal = data.min() ?? 0
            let maxVal = data.max() ?? 1

            var path = Path()

            // P2 Fix: When all values are equal, draw a flat line at center
            if maxVal == minVal {
                let midY = size.height / 2
                path.move(to: CGPoint(x: 0, y: midY))
                path.addLine(to: CGPoint(x: size.width, y: midY))
            } else {
                let range = maxVal - minVal
                let stepX = size.width / CGFloat(data.count - 1)

                for (i, value) in data.enumerated() {
                    let x = CGFloat(i) * stepX
                    let y = size.height - ((CGFloat(value - minVal) / CGFloat(range)) * size.height * 0.8 + size.height * 0.1)

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }

            let color: Color = {
                switch trend {
                case .up: return OddsTheme.lime
                case .down: return OddsTheme.downRed
                case .flat: return OddsTheme.text3
                }
            }()

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
