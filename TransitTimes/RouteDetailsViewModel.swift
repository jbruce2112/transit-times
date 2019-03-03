import Foundation
import WatchConnectivity

protocol RouteDetailsViewModel {
    var reload: (() -> Void)? { get set }
    var name: String { get }
    var names: [String] { get }
    var directionNames: [String] { get }
    var nameToTag: [String: String] { get }
    var directionIndex: Int { get set }
    
    func fetchDetails()
    func addFavorite(row: Int)
    func fetchPredictions(stop: Stop, completion: @escaping (([Predictions]?) -> Void))    
}

class RouteDetailsViewModelImpl: RouteDetailsViewModel {
    
    var reload: (() -> Void)?
    let name: String
    var names = [String]()
    var nameToTag = [String: String]()
    var directionNames = [String]()
    
    var directionIndex: Int = 0 {
        didSet {
            fetchDetails()
        }
    }
    
    private let routeTag: String
    private let service: NextBusService
    init(routeTag: String,
         name: String,
         service: NextBusService = NextBusServiceImpl()) {
        self.routeTag = routeTag
        self.service = service
        self.name = name
    }
    
    func fetchDetails() {
        self.service.fetchRouteDetails(routeTag: routeTag) { [weak self] routeDetails in
            guard let routeDetails = routeDetails, let strongSelf = self else {
                return
            }
            var dict = [String: String]()
            var newNames = [String]()
            let stops = routeDetails.stop
            let stopsInThisDirection = routeDetails.direction[strongSelf.directionIndex].stop.map { $0.tag }
            for stopTag in stopsInThisDirection {
                if let name = stops.first(where: { $0.tag == stopTag })?.title {
                    dict[name] = stopTag
                    newNames.append(name)
                }
            }
            self?.nameToTag = dict
            self?.names = newNames
            self?.directionNames = routeDetails.direction.filter { $0.useForUI == "true" }.map { $0.name }
            self?.reload?()
        }
    }
    
    func fetchPredictions(stop: Stop, completion: @escaping (([Predictions]?) -> Void)) {
        service.fetchPredictions(stops: [Stop(route: routeTag, tag: stop.tag)], completion: completion)
    }
    
    func addFavorite(row: Int) {
        let name = names[row]
        guard let tag = nameToTag[name] else {
            return
        }
        
        var currentFavorites = UserDefaults.standard.array(forKey: "favorites") as? [[String: String]] ?? [[String: String]]()
        if !currentFavorites.contains(where: { $0["routeTag"] == routeTag && $0["stopTag"] == tag }) {
            var newFavorite = [String: String]()
            newFavorite["name"] = name
            newFavorite["routeTag"] = routeTag
            newFavorite["stopTag"] = tag
            currentFavorites.append(newFavorite)
            UserDefaults.standard.set(currentFavorites, forKey: "favorites")
        }
        updateWatchFavorites(favorites: currentFavorites)
    }
    
    private func updateWatchFavorites(favorites: [[String: String]]) {
        let session = WCSession.default
        var contents = [String: Any]()
        contents["favorites"] = favorites
        do {
            try session.updateApplicationContext(contents)
            print("successfully updated favorites on watch")
        } catch let error {
            print("error update favorites on watch \(error)")
        }
    }
}
