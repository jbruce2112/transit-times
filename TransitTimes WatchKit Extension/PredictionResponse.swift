import Foundation

struct PredictionResponse: Codable {
    let predictions: [Predictions]?
    let copyright: String
}

struct Predictions: Codable {
    let message: Message?
    let agencyTitle, routeTag, routeTitle: String
    let direction: Direction
    let stopTitle, stopTag: String
}

struct Direction: Codable {
    let title: String
    let prediction: [DirectionPrediction]
}

struct DirectionPrediction: Codable {
    let isDeparture, minutes, seconds, tripTag: String
    let vehicle, block: String
    let epochTime: String
    let affectedByLayover: String?
}

struct Message: Codable {
    let text, priority: String
}
