import UIKit
import NerauModel

extension TrainResult {
    /// Convert a result into a UIImage that shows the areas which the user excels at and not
    func resultImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let tileSize = (x: size.width / CGFloat(TrainResult.mapSize.0), y: size.height / CGFloat(TrainResult.mapSize.1))
        for (index, value) in strengthMap.enumerated() {
            let row = CGFloat(index / TrainResult.mapSize.0)
            let col = CGFloat(index % TrainResult.mapSize.1)
            let rect = CGRect(x: col * tileSize.x, y: row * tileSize.y, width: tileSize.x, height: tileSize.y)
            let color = UIColor(white: CGFloat(1.0 - value), alpha: 1.0)
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)

        }
        ctx.setFillColor(UIColor.red.cgColor)
        ctx.fill(CGRect(x: size.width / 2 - 1, y: 0, width: 2, height: size.height))
        ctx.fill(CGRect(x: 0, y: size.height / 2 - 1, width: size.width, height: 2))
        ctx.setStrokeColor(UIColor.darkGray.cgColor)
        ctx.stroke(CGRect(origin: CGPoint.zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img!
    }
}

final class ResultWrappingController: UIViewController {
    public var result: TrainResult?

    @IBAction func doClose(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedResult"?:
            (segue.destination as? ResultController)?.result = result
        default: fatalError("Unknown Segue \(segue.identifier ?? "Anon")")
        }
    }
}

final class ResultController: UIViewController {
    
    public var result: TrainResult?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var durationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = self.result!.resultImage(size: imageView.frame.size)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultList" {
            (segue.destination as? ResultTimeIntervalListController)?.dataPoints = result!.durationPoints.map { $0.1 }
        }
    }
}
