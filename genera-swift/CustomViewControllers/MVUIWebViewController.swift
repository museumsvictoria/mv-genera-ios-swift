//
//  MVUIWebViewController.swift
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

class MVUIWebViewController: UIViewController, UIWebViewDelegate {

    var customWebView: UIWebView?
    var speci:Speci?
    var templateFilename:String? = ""
    var displayHTML:String = "<html><h1>Default Display HTML</h1></html>"
    var templateHTML:String? = ""
    let baseURL = Bundle.main.bundleURL
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.customWebView = UIWebView()
        self.customWebView?.delegate = self;
        customWebView!.backgroundColor = UIColor.clear
        customWebView!.isOpaque = false
        
        self.view = self.customWebView
        
        if ( speci != nil) {
            setupTemplate()
        }
    }
    
    
    func setupTemplate(){
        
        //get template
        let templatePath:String? = templateFilename?.FileLocation
        
        do{
            if let realTemplatePath = templatePath{
                displayHTML = try String(contentsOfFile:realTemplatePath)
            }else
            { //templateFile hasn't been defined use default template
                print("template location: \("template-ipad.html".FileLocation)")
                displayHTML = try String(contentsOfFile: "template-ipad.html".FileLocation)
                
            }
            
            
            transformTemplate()
            
            
        }
        catch{
            customWebView!.loadHTMLString("<html><h1 style=\"color:white\">An Error has occured in processing the tempalte</h1></html>", baseURL: baseURL)
        }
        
    
        
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
    
    
    func refreshTemplate(){
        
        if let displayHTML = templateHTML{
            self.displayHTML = displayHTML
            transformTemplate()
        }else
        {
            displayHTML = ""
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
        customWebView!.loadHTMLString(displayHTML, baseURL: baseURL)
    }
    
    
    func replacePlaceholder(_ placeholder:String, with:String?){
        
        if let replacementString = with {
            if placeholder.contains("_file"){
                //find filepath
                let filepath = replacementString.FileLocation
                displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)%>", with:filepath)
                displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)Class%>", with: replacementString)
                
            }else
            {
                if replacementString == "" { //where a entry has no value, set the class placeholder to "invisible"
                    displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)%>", with:"")
                    displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)Class%>", with: "invisible")
                }else{
                    displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)%>", with:replacementString)
                    displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)Class%>", with: replacementString)
                }
            }
            
        } else // string is null, so treat as blank
        {
            displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)%>", with:"")
            displayHTML = displayHTML.replacingOccurrences(of: "<%\(placeholder)Class%>", with: "invisible")
            
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
                for audio in audios.sorted(by: >){
                    audioSetup = audioSetup + "var audio\(audioCounter) = new Audio(\"\(audio.FilePath())\");"
                    audioCredits = audioCredits + " <div class=\"audiocredit\">\(audio.credit ?? "")</div>"
                    audioNames = audioNames + " <div class=\"play\" id=\"audio\(audioCounter)div\" onclick=\"toggleAudio('audio\(audioCounter)div', audio\(audioCounter);\"> \(audio.audioDescription ?? "")</div>"
                    audioCounter += 1
                    
                }
                
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
