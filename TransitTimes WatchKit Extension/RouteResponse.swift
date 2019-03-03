import Foundation

struct RouteResponse: Codable {
    let route: [Route]
}

struct Route: Codable {
    let title, tag: String
}
