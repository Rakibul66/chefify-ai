import Foundation

// Define the response structure
struct SearchResponse: Decodable {
    let images: [ImageData]
}

struct ImageData: Identifiable, Codable {
    let id = UUID() // UUID is automatically Encodable/Decodable
    let title: String
    let imageUrl: String
    let source: String
    let link: String
}
