import Foundation

struct Stop {
    let route: String
    let tag: String
}

protocol NextBusService {
    func fetchPredictions(stops: [Stop], completion: @escaping (([Predictions]?) -> Void))
    func fetchRoutes(completion: @escaping (([Route]?) -> Void))
    func fetchRouteDetails(routeTag: String, completion: @escaping ((RouteDetails?) -> Void))
}

struct NextBusServiceImpl: NextBusService {
    let session: URLSession = URLSession.shared
    
    func fetchRoutes(completion: @escaping (([Route]?) -> Void)) {
        let mainThreadCompletion: (([Route]?) -> Void) = { routes in
            DispatchQueue.main.async {
                completion(routes)
            }
        }
        guard let url = routeURL() else {
            mainThreadCompletion(nil)
            return
        }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                mainThreadCompletion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(RouteResponse.self, from: data)
                mainThreadCompletion(response.route)
            } catch let error {
                print(error)
                mainThreadCompletion(nil)
            }
        }.resume()
    }
    
    func fetchRouteDetails(routeTag: String, completion: @escaping ((RouteDetails?) -> Void)) {
        let mainThreadCompletion: ((RouteDetails?) -> Void) = { details in
            DispatchQueue.main.async {
                completion(details)
            }
        }
        guard let url = routeDetailsURL(routeTag: routeTag) else {
            mainThreadCompletion(nil)
            return
        }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                mainThreadCompletion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(RouteDetailsResponse.self, from: data)
                mainThreadCompletion(response.route)
            } catch let error {
                print(error)
                mainThreadCompletion(nil)
            }
        }.resume()
    }
    
    func fetchPredictions(stops: [Stop], completion: @escaping (([Predictions]?) -> Void)) {
        let mainThreadCompletion: (([Predictions]?) -> Void) = { predictions in
            DispatchQueue.main.async {
                completion(predictions)
            }
        }
        guard let url = predictionURL(stops: stops) else {
            mainThreadCompletion(nil)
            return
        }
        session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                mainThreadCompletion(nil)
                return
            }
            do {
                let str = String(data: data, encoding: .utf8)!
                print(str)
                let response = try JSONDecoder().decode(PredictionResponse.self, from: data)
                mainThreadCompletion(response.predictions)
            } catch let error {
                print(error)
                mainThreadCompletion(nil)
            }
        }.resume()
    }
    
    private func routeURL() -> URL? {
        var components = URLComponents(string: "http://webservices.nextbus.com/service/publicJSONFeed")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "command", value: "routeList"))
        queryItems.append(URLQueryItem(name: "a", value: "sf-muni"))
        queryItems.append(URLQueryItem(name: "useShortTitles", value: "true"))
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    private func routeDetailsURL(routeTag: String) -> URL? {
        var components = URLComponents(string: "http://webservices.nextbus.com/service/publicJSONFeed")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "command", value: "routeConfig"))
        queryItems.append(URLQueryItem(name: "a", value: "sf-muni"))
        queryItems.append(URLQueryItem(name: "r", value: "\(routeTag)"))
        queryItems.append(URLQueryItem(name: "useShortTitles", value: "true"))
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    private func predictionURL(stops: [Stop]) -> URL? {
        var components = URLComponents(string: "http://webservices.nextbus.com/service/publicJSONFeed")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "command", value: "predictionsForMultiStops"))
        queryItems.append(URLQueryItem(name: "a", value: "sf-muni"))
        queryItems.append(URLQueryItem(name: "useShortTitles", value: "true"))
        for stop in stops {
            queryItems.append(URLQueryItem(name: "stops", value: "\(stop.route)|\(stop.tag)"))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
