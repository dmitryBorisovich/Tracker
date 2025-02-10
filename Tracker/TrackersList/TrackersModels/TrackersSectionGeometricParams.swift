import Foundation

struct TrackersSectionGeometricParams {
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(leftInset: CGFloat, rightInset: CGFloat) {
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = 9
        self.paddingWidth = leftInset + rightInset + cellSpacing
    }
}
