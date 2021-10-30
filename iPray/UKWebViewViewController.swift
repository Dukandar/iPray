//
//  UKWebViewViewController.swift
//  iPray
//
//  Created by Sunilkumar Bassappa on 22/04/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import UIKit
import WebKit

class UKWebViewViewControllerI:UIViewController,WKNavigationDelegate{
    @IBOutlet weak var webKit : WKWebView!
    var URL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText: "")
        Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(initWebKit), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    
    @objc func initWebKit(){
     self.webKit.navigationDelegate = self
     let url = NSURL(string: self.URL)
     self.webKit.load(URLRequest(url: url! as URL))
     self.webKit.allowsBackForwardNavigationGestures = true
    }
    
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ServiceUtility.hideProgressHudInView()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ServiceUtility.hideProgressHudInView()
    }

}

