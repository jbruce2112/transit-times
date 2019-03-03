import Foundation
import WatchKit

class FavoritesController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var loadingIndicator: WKInterfaceImage!
    
    var viewModel: FavoritesViewModel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.viewModel = FavoritesViewModel()
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
