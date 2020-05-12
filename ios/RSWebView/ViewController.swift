

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, FrameExtractorDelegate {
    var count = 0
    func captured(image: UIImage) {
        count += 1
        if count % 10 == 0 {
            let imageData = image.pngData()
            let base64 = imageData!.base64EncodedString()
            let javascript = "window.app.cameraFrame('\(base64)')"
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
    
    let cameraHandler = "cameraHandler"
    var webView: WKWebView!
    var frameExtractor: FrameExtractor!
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == cameraHandler {
            guard let dict = message.body as? [String: AnyObject],
                let operation = dict["operation"] as? String else {
                    return
            }
            if operation == "start" {
                frameExtractor.start()
            } else if operation == "stop" {
                frameExtractor.stop()
            }
        }
    }
    
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: cameraHandler)
        webView = WKWebView(frame: CGRect.zero, configuration: configuration )
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource:"App/index", ofType:"html") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        //let url = URL(string: "http://192.168.0.6:9000")!
        webView.load(URLRequest(url: url))
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    


}

