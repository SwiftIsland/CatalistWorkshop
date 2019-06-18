import UIKit
import NerauModel

class TrainingViewController: UIViewController {
    
    private var controlsViewController: TrainingControlsTableViewController?
    
    @IBAction func doBeginTraining(sender: UIButton) {
        guard let config = controlsViewController?.calculatedConfiguration else { return }
        let controller = TrainController(configuration: config)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        let alert = UIAlertController(title: "Search For", message: controller.startupMessage(), preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (_) in
            self.present(controller, animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "resultController"?:
            if let resultController = segue.destination as? ResultController {
                resultController.result = sender as? TrainResult
            } else if let wrapController = segue.destination as? ResultWrappingController {
                wrapController.result = sender as? TrainResult
            }
        case "EmbedSegue":
            controlsViewController = segue.destination as? TrainingControlsTableViewController
        default: fatalError("Unknown Segue \(segue.identifier ?? "Anon")")
        }
    }
}

extension TrainingViewController: TrainControllerDelegate {
    func didFinishTraining(result: TrainResult, controller: TrainController) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "resultController", sender: result)
        }
    }
    
    func didCancelTraining(controller: TrainController) {
        controller.dismiss(animated: true)
    }
}
