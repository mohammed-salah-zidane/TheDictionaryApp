import SwiftUI

/// A custom layout that arranges views in a flowing manner, similar to how text wraps.
public struct FlowLayout: Layout {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    
    public init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            containerWidth: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            containerWidth: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(
                at: CGPoint(
                    x: bounds.minX + point.x,
                    y: bounds.minY + point.y
                ),
                proposal: .unspecified
            )
        }
    }
}

// MARK: - Helper Types
private extension FlowLayout {
    struct FlowResult {
        let size: CGSize
        let points: [CGPoint]
        
        init(containerWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var size = CGSize(width: containerWidth, height: 0)
            var points: [CGPoint] = []
            var lineHeight: CGFloat = 0
            var lineY: CGFloat = 0
            var lineX: CGFloat = 0
            
            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)
                
                if lineX + viewSize.width > containerWidth && !points.isEmpty {
                    lineY += lineHeight + spacing
                    lineHeight = 0
                    lineX = 0
                }
                
                points.append(CGPoint(x: lineX, y: lineY))
                lineHeight = max(lineHeight, viewSize.height)
                lineX += viewSize.width + spacing
                size.width = max(size.width, lineX)
            }
            
            size.height = lineY + lineHeight
            self.size = size
            self.points = points
        }
    }
}
