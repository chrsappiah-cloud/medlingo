import SwiftUI

enum AppColor {
    // Premium luxury primaries
    static let primary = Color(hex: "1B2838")
    static let primaryDark = Color(hex: "0D1B2A")
    static let primaryLight = Color(hex: "415A77")

    // Accent metals
    static let gold = Color(hex: "D4AF37")
    static let goldLight = Color(hex: "F5E6A3")
    static let goldShimmer = Color(hex: "FFD700")

    static let diamond = Color(hex: "B9F2FF")
    static let diamondDeep = Color(hex: "7EC8E3")
    static let diamondWhite = Color(hex: "E8F8FF")

    static let emerald = Color(hex: "50C878")
    static let emeraldDeep = Color(hex: "046307")
    static let emeraldShine = Color(hex: "A8E6CF")

    static let pearl = Color(hex: "FDEEF4")
    static let pearlWarm = Color(hex: "FFF8F0")
    static let pearlCool = Color(hex: "F0F4FD")

    static let platinum = Color(hex: "E5E4E2")
    static let platinumDark = Color(hex: "8E8D8A")

    // Surfaces
    static let background = Color(hex: "0D1117")
    static let surface = Color(hex: "161B22")
    static let surfaceElevated = Color(hex: "1C2432")
    static let surfaceGlass = Color.white.opacity(0.06)

    // Text
    static let textPrimary = Color(hex: "F0F6FC")
    static let textSecondary = Color(hex: "8B949E")
    static let textTertiary = Color(hex: "484F58")

    // Status
    static let success = Color(hex: "50C878")
    static let warning = Color(hex: "D4AF37")
    static let error = Color(hex: "F85149")
    static let info = Color(hex: "7EC8E3")

    // Engagement
    static let streakOrange = Color(hex: "FF6B35")
    static let xpGold = Color(hex: "FFD700")

    // Stage colors — luxury gem progression
    static let stageColors: [Color] = [
        Color(hex: "B9F2FF"), // Diamond - Stage 1
        Color(hex: "D4AF37"), // Gold - Stage 2
        Color(hex: "50C878"), // Emerald - Stage 3
        Color(hex: "E6E6FA"), // Pearl/Lavender - Stage 4
        Color(hex: "FF6B9D"), // Rose Gold - Stage 5
        Color(hex: "7B68EE"), // Amethyst - Stage 6
        Color(hex: "FFD700"), // Gold Shimmer - Stage 7
        Color(hex: "FF4500"), // Ruby - Stage 8
        Color(hex: "00CED1"), // Aquamarine - Stage 9
        Color(hex: "9370DB"), // Crystal Purple - Stage 10
        Color(hex: "20B2AA"), // Jade - Stage 11
        Color(hex: "FF8C00"), // Amber - Stage 12
        Color(hex: "4169E1"), // Sapphire - Stage 13
        Color(hex: "DC143C"), // Garnet - Stage 14
        Color(hex: "C0C0C0"), // Silver - Stage 15
    ]

    // Premium gradients
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "D4AF37"), Color(hex: "F5E6A3"), Color(hex: "D4AF37")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let diamondGradient = LinearGradient(
        colors: [Color(hex: "B9F2FF"), Color(hex: "E8F8FF"), Color(hex: "7EC8E3")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let emeraldGradient = LinearGradient(
        colors: [Color(hex: "046307"), Color(hex: "50C878"), Color(hex: "A8E6CF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkGradient = LinearGradient(
        colors: [Color(hex: "0D1117"), Color(hex: "161B22"), Color(hex: "1C2432")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "1B2838"), Color(hex: "0D1B2A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
