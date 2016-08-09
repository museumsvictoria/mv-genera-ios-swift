//
//  Speci.swift
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
import CoreData


class Speci: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    func provideHTMLforTablet() -> String{
        var HTML = ""
        HTML =  "<html><h1>Default Display HTML</h1></html>"
        //get template
        return HTML
    }
    
    func provideHTMLforPhoneTab(tabNumber:Int) -> String{
        var HTML = ""
        HTML =  "<html><h1>Default Display HTML</h1></html>"
        //get tab template
        
        return HTML
    }
    
    func sortedImages() -> [Image]{
        var returnArray:[Image] = []
        if self.images!.count > 0{
            returnArray = Array(self.images!)
            returnArray = returnArray.sort({$0<$1})
        }
        return returnArray
    }
    
    func sortedAudio() -> [Audio]{
        var returnArray:[Audio] = []
        if self.audios!.count > 0{
            returnArray = Array(self.audios!)
            returnArray = returnArray.sort({$0<$1})
        }
        return returnArray
    }

}
