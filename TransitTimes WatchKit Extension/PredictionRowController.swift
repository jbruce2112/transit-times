import WatchKit

class PredictionRowController: NSObject {

    @IBOutlet var routeTitle: WKInterfaceLabel!
    @IBOutlet var stop: WKInterfaceLabel!
    @IBOutlet var firstPrediction: WKInterfaceLabel!
    @IBOutlet var secondPrediction: WKInterfaceLabel!
    @IBOutlet var thirdPrediction: WKInterfaceLabel!
    
    func update(predictions: Predictions) {
        routeTitle.setText(predictions.routeTitle)
        stop.setText(predictions.stopTitle)
        firstPrediction.setText(minutes(predictions.direction, 0))
        secondPrediction.setText(minutes(predictions.direction, 1))
        thirdPrediction.setText(minutes(predictions.direction, 2))
    }
    
    private func minutes(_ direction: Direction, _ index: Int) -> String {
        return index < direction.prediction.count  ? "\(direction.prediction[index].minutes) min" : ""
    }
}
