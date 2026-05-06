import Foundation

enum AppConstants {
    static let appName = "Medlingo"
    static let copyright = "© 2026 World Class Scholars. All rights reserved."
    static let companyName = "World Class Scholars"
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let bundleID = "wcs.medlingo"
    static let supportEmail = "support@worldclassscholars.com"
    static let privacyURL = URL(string: "https://worldclassscholars.com/privacy")!
    static let termsURL = URL(string: "https://worldclassscholars.com/terms")!
}
