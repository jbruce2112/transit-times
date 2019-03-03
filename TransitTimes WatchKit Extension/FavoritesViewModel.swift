import Foundation

class FavoritesViewModel {
    
    private let service: NextBusService
    private let stops = [Stop(route: "6", id: "4958"),
                         Stop(route: "7", id: "4958")]
    
    init(service: NextBusService = NextBusServiceImpl()) {
        self.service = service
    }
    
    func fetchPredictions(completion: @escaping (([Predictions]?) -> Void)) {
        service.fetchPredictions(stops: stops, completion: completion)
    }
}
