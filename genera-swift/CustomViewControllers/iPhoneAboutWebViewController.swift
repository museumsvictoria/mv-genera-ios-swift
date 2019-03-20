//
//  iPhoneAboutWebViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 28/04/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import WebKit
class iPhoneAboutWebViewController: UIViewController, UIWebViewDelegate {

    
    var customWebView: UIWebView?
    
    var displayHTML:String = "<html><h1>Default Display HTML</h1></html>"
    let baseURL = Bundle.main.bundleURL

    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.customWebView = UIWebView()
        customWebView!.backgroundColor = UIColor.clear
        customWebView!.isOpaque = false
        self.customWebView?.delegate = self
        self.view = self.customWebView
        do{
            displayHTML = try String(contentsOfFile: "about-iphone.html".FileLocation)
        }
        catch{
            displayHTML = "<html><h1 style='color:white'>About Template Not Found</h1><p style='color:white'>The file : about-iphone.html could not be found. Please add it to the Template Directory</p>"
        }
        customWebView!.loadHTMLString(displayHTML, baseURL: baseURL)
        
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                                            navigationType: UIWebView.NavigationType) -> Bool{
        
        if (navigationType == UIWebView.NavigationType.linkClicked){
            UIApplication.shared.openURL((request.mainDocumentURL)!)
            return false
            
        }
        
        
        return true
    }

}
