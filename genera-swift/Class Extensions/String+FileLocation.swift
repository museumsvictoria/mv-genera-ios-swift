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
        
        let bareFileName:String? = (NSURL(fileURLWithPath: self).URLByDeletingPathExtension?.path)
        let fileExtension:String? = NSURL(fileURLWithPath: self).pathExtension
      
        print("Filename: \(bareFileName), Extension: \(fileExtension)")
        if let testImages = NSBundle.mainBundle().pathForResource(bareFileName, ofType: fileExtension, inDirectory: "Images")
        {
            returnPath = testImages
        }
        if let testAudio = NSBundle.mainBundle().pathForResource(bareFileName, ofType: fileExtension, inDirectory: "Audio")
        {
            returnPath = testAudio
        }
        if let testTemplates = NSBundle.mainBundle().pathForResource(bareFileName, ofType: fileExtension, inDirectory: "Templates")
        {
            returnPath = testTemplates
        }
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        
        guard urls.count == 0 else{
            //Application Support Directory hasn't been created - no updates to search - end function here.
            return returnPath ?? ""
        }
        
        let testUpdatePath = urls.first!.URLByAppendingPathComponent("/updates/\(self)")
        if fileManager.fileExistsAtPath(testUpdatePath.absoluteString){
                returnPath = testUpdatePath.absoluteString
            
        }
        
        return returnPath ?? ""
    }
    
    
    func AttributedString() -> NSMutableAttributedString{
        let paragraphString = "\(self)"
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: paragraphString)
        let nstext = NSMutableString(string: paragraphString)
        let attribute1 = [NSObliquenessAttributeName : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        var theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
        while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(attribute1, range: combinedRange)
                    mutableAttributedString.replaceCharactersInRange(theRange2, withString: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharactersInRange(theRange1, withString: "")
                    nstext.replaceCharactersInRange(theRange2, withString: "")
                    nstext.replaceCharactersInRange(theRange1, withString: "")
                }
            //Check for more EM tags
            theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
            theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
            
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
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: mutableAttributedString.length))
       
        return mutableAttributedString
    }
    
    func AttributedString(font: UIFont) -> NSMutableAttributedString{
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        let nstext = NSMutableString(string: self)
        let attribute1 = [NSObliquenessAttributeName : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        var theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
            while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(attribute1, range: combinedRange)
                    mutableAttributedString.replaceCharactersInRange(theRange2, withString: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharactersInRange(theRange1, withString: "")
                    nstext.replaceCharactersInRange(theRange2, withString: "")
                    nstext.replaceCharactersInRange(theRange1, withString: "")
                }
                //Check for more EM tags
                theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
                theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
                
            }
            
            
        }
        
        
        
        return mutableAttributedString
    }

    
    func AttributedStringNoIndent() -> NSMutableAttributedString{
        let paragraphString = "\(self)"
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: paragraphString)
        let nstext = NSMutableString(string: paragraphString)
        let attribute1 = [NSObliquenessAttributeName : "0.3" ] //Substitute for Italic given various font sizes
        
        var theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        var theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        if (theRange1.location != NSNotFound && theRange2.location != NSNotFound) //maked sure there's a pair
        {
            while (theRange1.location != NSNotFound && theRange2.location != NSNotFound){
                let combinedRange = NSUnionRange(theRange1, theRange2)
                if (combinedRange.length > 0){
                    mutableAttributedString.addAttributes(attribute1, range: combinedRange)
                    mutableAttributedString.replaceCharactersInRange(theRange2, withString: "") //order of removal is important! Have to work backwards down the range
                    mutableAttributedString.replaceCharactersInRange(theRange1, withString: "")
                    nstext.replaceCharactersInRange(theRange2, withString: "")
                    nstext.replaceCharactersInRange(theRange1, withString: "")
                }
                //Check for more EM tags
                theRange1 = nstext.rangeOfString("<em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
                theRange2 = nstext.rangeOfString("</em>", options: NSStringCompareOptions.CaseInsensitiveSearch)
                
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
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: mutableAttributedString.length))
        
        return mutableAttributedString
    }
    
}

