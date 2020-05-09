//
//  ViewController.swift
//  IOSWebViewTutorial
//
//  Created by Arthur Knopper on 29/03/2019.
//  Copyright © 2019 Arthur Knopper. All rights reserved.
//

import UIKit
import WebKit

extension NSURLRequest {
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        return true
    }
}

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        guard let path = Bundle.main.path(forResource:"index", ofType:"html") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        webView.load(URLRequest(url: url))
        
        // 2
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }


}

