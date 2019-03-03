import Foundation

struct Stop {
    let route: String
    let id: String
}

protocol NextBusService {
    func fetchPredictions(stops: [Stop], completion: @escaping (([Predictions]?) -> Void))
}

struct NextBusServiceImpl: NextBusService {
    let session: URLSession
    
    init() {
        self.session = URLSession.shared
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
                let response = try JSONDecoder().decode(PredictionResponse.self, from: data)
                mainThreadCompletion(response.predictions)
            } catch let error {
                print(error)
                mainThreadCompletion(nil)
            }
        }.resume()
    }
    
    private func predictionURL(stops: [Stop]) -> URL? {
        var components = URLComponents(string: "http://webservices.nextbus.com/service/publicJSONFeed")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "command", value: "predictionsForMultiStops"))
        queryItems.append(URLQueryItem(name: "a", value: "sf-muni"))
        queryItems.append(URLQueryItem(name: "useShortTitles", value: "true"))
        for stop in stops {
            queryItems.append(URLQueryItem(name: "stops", value: "\(stop.route)|\(stop.id)"))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
