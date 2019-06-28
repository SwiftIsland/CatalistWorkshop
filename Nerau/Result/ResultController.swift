import UIKit
import NerauModel

class ResultHoverView: UIView {
    public var trainResult: TrainResult? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let strengthMap = trainResult?.strengthMap else { return }
        let size = rect.size
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
    
    static let SomethingTouchBarIdentifier = NSTouchBarItem.Identifier(rawValue: "ToggleStar")
    
    public var result: TrainResult?
    
    @IBOutlet weak var containerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var durationField: UITextField!
    
    @IBOutlet weak var hoverView: ResultHoverView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        navigationController?.setNavigationBarHidden(false, animated: true)
        bottomToolbar.removeFromSuperview()
        containerViewBottom.constant = 0
        #endif
        
        hoverView.trainResult = self.result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultList" {
            (segue.destination as? ResultTimeIntervalListController)?.dataPoints = result!.durationPoints.map { $0.1 }
        }
    }
    
    @objc func toggleStar(sender: Any) {
        result?.stared.toggle()
        guard let r = result else { return }
        Database.shared.toggleStarResult(result: r)
        self.touchBar = self.makeTouchBar()
    }
}

#if targetEnvironment(UIKitForMac)
extension ResultController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [ResultController.SomethingTouchBarIdentifier]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        guard let r = result else { return nil }
        switch identifier {
        case ResultController.SomethingTouchBarIdentifier:
            return NSButtonTouchBarItem.init(identifier: identifier,
                                             title: r.stared ? "Unstar" : "Star",
                                             target: self,
                                             action: #selector(self.toggleStar(sender:)))
        default:
            return nil
        }
    }
}

#endif
