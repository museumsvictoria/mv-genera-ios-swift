//
//  String+FileLocation.swift
//  genera-swift
//
//  Created by Simon Sherrin on 19/01/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import Foundation
import UIKit

extension String
{
    var FileLocation:String{
        var returnPath:String?
        
        let bareFileName:String? = (NSURL(fileURLWithPath: self).deletingPathExtension?.path)
        let fileExtension:String? = URL(fileURLWithPath: self).pathExtension
      
        print ("Looking for \(self)")
//       print("Filename: \(String(describing: bareFileName)), Extension: \(String(describing: fileExtension))")
        if let testImages = Bundle.main.path(forResource: bareFileName, ofType: fileExtension, inDirectory: "images")
        {
            print("Found \(self) in images")
            returnPath = testImages
        }
        if let testAudio = Bundle.main.path(forResource: bareFileName, ofType: fileExtension, inDirectory: "audio")
        {
            print("Found \(self) in audio")
            returnPath = testAudio
        }
        if let testTemplates = Bundle.main.path(forResource: bareFileName, ofType: fileExtension, inDirectory: "templates")
        {
            print("Found \(self) in templates")
            returnPath = testTemplates
        }
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard urls.count == 0 else{
            //Application Support Directory hasn't been created - no updates to search - end function here.
            if returnPath == nil || returnPath == "" {
                print ("Couldn't find \(self) in bundle")
            }
            return returnPath ?? ""
        }
        
        let testUpdatePath = urls.first!.appendingPathComponent("/updates/\(self)")
        if fileManager.fileExists(atPath: testUpdatePath.absoluteString){
                returnPath = testUpdatePath.absoluteString
            
        }
        if returnPath == nil || returnPath == "" {
            print ("Couldn't find \(self) in bundle")
        }
        
        return returnPath ?? ""
    }
    
    
    func AttributedString() -> NSMutableAttributedString{
        let paragraphString = "\(self)"
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: paragraphString)
        let nstext = NSMutableString(string: paragraphString)
        let attribute1 = [convertFromNSAttributedStringKey(NSAttributedString.Key.obliqueness) : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
        var theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
        while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(convertToNSAttributedStringKeyDictionary(attribute1), range: combinedRange)
                    mutableAttributedString.replaceCharacters(in: theRange2, with: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharacters(in: theRange1, with: "")
                    nstext.replaceCharacters(in: theRange2, with: "")
                    nstext.replaceCharacters(in: theRange1, with: "")
                }
            //Check for more EM tags
            theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
            theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
            
            }

            
        }
    
       let paraStyle = NSMutableParagraphStyle()
        paraStyle.headIndent = 15.0
        paraStyle.tailIndent = -10.0
        paraStyle.firstLineHeadIndent = 15.0
        paraStyle.paragraphSpacingBefore = 0.0
        paraStyle.paragraphSpacing = 20.0
        paraStyle.minimumLineHeight = 0.0
        
     //   paraStyle.lineSpacing = 10.0
       
        // Apply paragraph styles to paragraph
        mutableAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: NSRange(location: 0,length: mutableAttributedString.length))
       
        return mutableAttributedString
    }
    
    func AttributedString(_ font: UIFont) -> NSMutableAttributedString{
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        let nstext = NSMutableString(string: self)
        let attribute1 = [convertFromNSAttributedStringKey(NSAttributedString.Key.obliqueness) : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
        var theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
            while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(convertToNSAttributedStringKeyDictionary(attribute1), range: combinedRange)
                    mutableAttributedString.replaceCharacters(in: theRange2, with: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharacters(in: theRange1, with: "")
                    nstext.replaceCharacters(in: theRange2, with: "")
                    nstext.replaceCharacters(in: theRange1, with: "")
                }
                //Check for more EM tags
                theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
                theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
                
            }
            
            
        }
        
        
        
        return mutableAttributedString
    }

    
    func AttributedStringNoIndent() -> NSMutableAttributedString{
        let paragraphString = "\(self)"
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: paragraphString)
        let nstext = NSMutableString(string: paragraphString)
        let attribute1 = [convertFromNSAttributedStringKey(NSAttributedString.Key.obliqueness) : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
        var theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
            while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(convertToNSAttributedStringKeyDictionary(attribute1), range: combinedRange)
                    mutableAttributedString.replaceCharacters(in: theRange2, with: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharacters(in: theRange1, with: "")
                    nstext.replaceCharacters(in: theRange2, with: "")
                    nstext.replaceCharacters(in: theRange1, with: "")
                }
                //Check for more EM tags
                theRange1 = nstext.range(of: "<em>", options: NSString.CompareOptions.caseInsensitive)
                theRange2 = nstext.range(of: "</em>", options: NSString.CompareOptions.caseInsensitive)
                
            }
            
            
        }
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.headIndent = 0.0
        paraStyle.tailIndent = 0.0
        paraStyle.firstLineHeadIndent = 0.0
        paraStyle.paragraphSpacingBefore = 0.0
        paraStyle.paragraphSpacing = 20.0
        paraStyle.minimumLineHeight = 0.0
        
        //   paraStyle.lineSpacing = 10.0
        
        // Apply paragraph styles to paragraph
        mutableAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: NSRange(location: 0,length: mutableAttributedString.length))
        
        return mutableAttributedString
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
