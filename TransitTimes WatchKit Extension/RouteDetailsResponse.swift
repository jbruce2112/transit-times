import Foundation

struct RouteDetailsResponse: Codable {
    let route: RouteDetails
}

struct RouteDetails: Codable {
    let latMax: String
    let stop: [RouteStop]
    let title, lonMin, color: String
    let direction: [RouteDirection]
    let tag: String
    let path: [Path]
    let lonMax, oppositeColor, latMin: String
}

struct RouteDirection: Codable {
    let stop: [DirectionStop]
    let title, useForUI, tag, name: String
}

struct DirectionStop: Codable {
    let tag: String
}

struct Path: Codable {
    let point: [Point]
}

struct Point: Codable {
    let lon, lat: String
}

struct RouteStop: Codable {
    let lon, title, stopID, tag: String
    let lat: String
    
    enum CodingKeys: String, CodingKey {
        case lon, title
        case stopID = "stopId"
        case tag, lat
    }
}
