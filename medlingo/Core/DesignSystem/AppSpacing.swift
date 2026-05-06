import SwiftUI

enum AppSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

enum AppShadow {
    static let sm = ShadowStyle(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let md = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let lg = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}
