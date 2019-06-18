import UIKit

public final class HelpContactController: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let htmlFile = Bundle.main.path(forResource: "help", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: nil)
    }
}
