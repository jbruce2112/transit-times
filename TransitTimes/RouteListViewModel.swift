import Foundation

protocol RouteListViewModel {
    var reload: (() -> Void)? { get set }
    var routes: [Route] { get }
    var name: String { get }
    
    func fetchRoutes()
}

class RouteListViewModelImpl: RouteListViewModel {
    var reload: (() -> Void)?
    
    var routes = [Route]()
    let name = "Routes"
    
    private let service: NextBusService
    init(service: NextBusService = NextBusServiceImpl()) {
        self.service = service
    }
    
    func fetchRoutes() {
        service.fetchRoutes { [weak self] routes in
            guard let routes = routes else {
                return
            }
            self?.routes = routes
            self?.reload?()
        }
    }
}
