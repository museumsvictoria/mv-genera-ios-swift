//
//  MVWebWrapperViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 5/05/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import WebKit

@IBDesignable class MVWebWrapperViewController: UIViewController, WKNavigationDelegate, UIWebViewDelegate {
    
    weak var speci:Speci?
    @IBInspectable var templateFilename:String = ""
    var displayHTML:String = "<html><h1>Default Display HTML</h1></html>"
    var templateHTML:String = ""
    let baseURL = NSBundle.mainBundle().bundleURL
    var customUIWebView:UIWebView?
    var customWKWebView:WKWebView?
    let os = NSProcessInfo().operatingSystemVersion
    var doubleTap:UITapGestureRecognizer = UITapGestureRecognizer()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
      
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       doubleTap.numberOfTapsRequired = 2
      doubleTap.addTarget(self, action: #selector(MVWebWrapperViewController.DoubleTap))
        //self.view.addGestureRecognizer(doubleTap)
        
        // Do any additional setup after loading the view, typically from a nib.
        if os.majorVersion == 8{
            self.customUIWebView = UIWebView()
            self.customUIWebView?.delegate = self;
            customUIWebView!.backgroundColor = UIColor.clearColor()
            customUIWebView!.opaque = false
            customUIWebView!.scalesPageToFit = false;
           customUIWebView!.scrollView.addGestureRecognizer(doubleTap)
            self.view = self.customUIWebView
        }
        else{
            self.customWKWebView = WKWebView()
            customWKWebView?.backgroundColor = UIColor.clearColor()
            customWKWebView?.opaque = false
            self.customWKWebView?.navigationDelegate  = self
           self.customWKWebView?.scrollView.addGestureRecognizer(doubleTap)
            self.view = self.customWKWebView
        }
        
        if ( !templateFilename.isEmpty) {
            setupTemplate()
        }
        

    }
    
    func DoubleTap(){
        print("Fired")
    }
    
    
    func setupTemplate(){
        
        //get template
        let templatePath:String? = templateFilename.FileLocation
        
        do{
            if let realTemplatePath = templatePath{
                displayHTML = try String(contentsOfFile:realTemplatePath)
            }else 
            { //templateFile hasn't been defined use default template
                print("template location: \("template-ipad.html".FileLocation)")
                displayHTML = try String(contentsOfFile: "template-ipad.html".FileLocation)
                
            }
            
            if ( speci != nil) {
                transformTemplate()
            }else{
                self.loadHTMLString(displayHTML, baseURL: baseURL)
            }
            
        }
        catch{
            
            self.loadHTMLString("<html><h1 style=\"color:white\">An Error has occured in processing the template</h1></html>", baseURL: baseURL )

        }
        
        
        
    }
    
    
    func loadHTMLString(html:String, baseURL:NSURL){
        if (self.customUIWebView != nil){
            customUIWebView!.loadHTMLString(html, baseURL: baseURL)
        } else if (self.customWKWebView != nil){
            customWKWebView!.loadHTMLString(html, baseURL: baseURL)
        }
        
    }
    
    func webView(webView: UIWebView,
                 shouldStartLoadWithRequest request: NSURLRequest,
                                            navigationType: UIWebViewNavigationType) -> Bool{
        
        if (navigationType == UIWebViewNavigationType.LinkClicked){
            UIApplication.sharedApplication().openURL((request.mainDocumentURL)!)
            return false
            
        }
        
        
        return true
    }
    
    
    
    func webView(webView: WKWebView,
                 decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                 decisionHandler: (WKNavigationActionPolicy) -> Void){
        if navigationAction.navigationType == WKNavigationType.LinkActivated{
            UIApplication.sharedApplication().openURL(navigationAction.request.mainDocumentURL!)
            
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
        
    }
    
    
    
    func refreshTemplate(){
        
        if !templateHTML.isEmpty{
            self.displayHTML = templateHTML
            transformTemplate()
        }else
        {
            self.displayHTML = ""
        }
        
    }
    
    func transformTemplate(){
        
        replacePlaceholder("label", with: speci?.label)
        replacePlaceholder("sublabel", with: speci?.sublabel)
        replacePlaceholder("sublabelStyle", with: speci?.sublabelStyle)
        if speci != nil{
            if speci!.details != nil {
                let speciDetails:[String: String] = speci!.details as! [String: String]
                for (key, value) in speciDetails{
                    
                    replacePlaceholder(key, with: value)
                }
                
            }
            
        }
        
        customAudioSetup()
        
        
        self.loadHTMLString(displayHTML, baseURL: baseURL)


    }
    
    
    func replacePlaceholder(placeholder:String, with:String?){
        
        if let replacementString = with {
            if placeholder.containsString("_file"){
                //find filepath
                let filepath = replacementString.FileLocation
                displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)%>", withString:filepath)
                displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)Class%>", withString: replacementString)
                
            }else
            {
                if replacementString == "" { //where a entry has no value, set the class placeholder to "invisible"
                    displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)%>", withString:"")
                    displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)Class%>", withString: "invisible")
                }else{
                    displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)%>", withString:replacementString)
                    displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)Class%>", withString: replacementString)
                }
            }
            
        } else // string is null, so treat as blank
        {
            displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)%>", withString:"")
            displayHTML = displayHTML.stringByReplacingOccurrencesOfString("<%\(placeholder)Class%>", withString: "invisible")
            
        }
        
        
        
    }
    
    
    func customAudioSetup()
    {
        
        //Section for building audio - need repeater block
        
        var audioSetup:String = String()
        var audioNames:String = String()
        var audioCredits:String = String()
        var audioClass:String = String()
        if let audioSet = speci?.audios{
            if audioSet.count > 0{
                let audios = audioSet
                audioClass = "widget"
                var audioCounter:Int = 1
                for audio in audios.sort(>){
                    audioSetup = audioSetup + "var audio\(audioCounter) = new Audio(\"\(audio.FilePath())\");"
                    audioCredits = audioCredits + " <div class=\"audiocredit\">\(audio.credit ?? "")</div>"
                    audioNames = audioNames + " <div class=\"play\" id=\"audio\(audioCounter)div\" onclick=\"toggleAudio('audio\(audioCounter)div', audio\(audioCounter));\"> \(audio.audioDescription ?? "")</div>"
                    audioCounter += 1
                    
                }
                
            }else{
                audioClass="hidden"
            }
        } else
        {
            audioClass = "hidden"
        }
        replacePlaceholder("audioSetup", with: audioSetup)
        replacePlaceholder("audioClass", with:  audioClass)
        replacePlaceholder("audioCredits", with: audioCredits)
        replacePlaceholder("audioNames", with: audioNames)
        
    }
    
    
    //External Functions
    
    func nudgeUpContent(){
        
        if customUIWebView != nil{
            
            customUIWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            UIView.animateWithDuration(0.5, animations: {
               self.customUIWebView!.scrollView.contentOffset = CGPointMake(0, 300);
            })
        }
        if customWKWebView != nil{
            
            customWKWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            UIView.animateWithDuration(0.5, animations: {
                self.customWKWebView!.scrollView.contentOffset = CGPointMake(0, 300);
            })
        }
        
        
    }
    
    func returnToTop(){
        if customUIWebView != nil{
            
            //customUIWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            UIView.animateWithDuration(0.5, animations: {
                self.customUIWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            })
        }
        if customWKWebView != nil{
            
          //  customWKWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            UIView.animateWithDuration(0.5, animations: {
                self.customWKWebView!.scrollView.contentOffset = CGPointMake(0, 64);
            })
        }
        

        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}