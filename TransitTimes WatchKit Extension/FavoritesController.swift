import Foundation
import WatchKit
import WatchConnectivity

class FavoritesController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var loadingIndicator: WKInterfaceImage!
    
    var viewModel: FavoritesViewModel!
    var wcSession: WCSession?
    var favorites: [[String: String]]? = UserDefaults.standard.array(forKey: "favorites") as? [[String: String]] {
        didSet {
            UserDefaults.standard.set(favorites, forKey: "favorites")
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.viewModel = FavoritesViewModel(favorites: favorites)
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    override func willActivate() {
        super.willActivate()
        updateRows()
    }
    
    func updateRows() {
        startLoadingIndicator()
        viewModel.fetchPredictions { [weak self] predictions in
            guard let predictions = predictions else {
                self?.stopLoadingIndicator()
                return
            }
            self?.table?.setNumberOfRows(predictions.count, withRowType: "PredictionRowController")
            for (index, prediction) in predictions.enumerated() {
                let row = self?.table?.rowController(at: index) as? PredictionRowController
                row?.update(predictions: prediction)
            }
            self?.stopLoadingIndicator()
        }
    }
    
    private func startLoadingIndicator() {
        loadingIndicator.setHidden(false)
        loadingIndicator.setImageNamed("Activity")
        loadingIndicator.startAnimatingWithImages(in: NSRange(location: 0, length: 15),
                                                       duration: 1.0,
                                                       repeatCount: 0)
    }
    
    private func stopLoadingIndicator() {
        loadingIndicator.setHidden(true)
    }
}

extension FavoritesController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.favorites = session.receivedApplicationContext["favorites"] as? [[String: String]]
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        self.favorites = applicationContext["favorites"] as? [[String: String]]
    }
}
