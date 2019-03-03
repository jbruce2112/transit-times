import Foundation

class FavoritesViewModel {
    
    private let service: NextBusService
    private let stops: [Stop]
    
    init(favorites: [[String: String]]? = nil,
         service: NextBusService = NextBusServiceImpl()) {
        self.service = service
        var favoriteStops = [Stop]()
        for favorite in favorites ?? [] {
            guard let routeTag = favorite["routeTag"],
                let stopTag = favorite["stopTag"] else {
                    continue
            }
            favoriteStops.append(Stop(route: routeTag, tag: stopTag))
        }
        self.stops = favoriteStops
    }
    
    func fetchPredictions(completion: @escaping (([Predictions]?) -> Void)) {
        service.fetchPredictions(stops: stops, completion: completion)
    }
}
