//
//  PrivacyPolicyViewController.swift
//  WBikes
//
//  Created by Diego on 21/10/2020.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var htmlFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white
        let htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(htmlString!, baseURL: nil)
    }
    

}
