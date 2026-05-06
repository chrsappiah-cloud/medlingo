import Foundation

struct AppProduct: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let type: ProductType
    let priceCents: Int
    let features: [String]

    enum ProductType: String, Codable, Hashable {
        case subscription
        case chapterPack = "chapter_pack"
        case sessionBundle = "session_bundle"
        case institutionalPlan = "institutional_plan"
    }
}
