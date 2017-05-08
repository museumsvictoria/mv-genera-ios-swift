//
//  Audio.swift
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

func == (lhs: Audio, rhs: Audio) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func > (lhs:Audio, rhs:Audio) -> Bool {
    
    return lhs.actualOrder > rhs.actualOrder
}

func < (lhs:Audio, rhs:Audio) -> Bool {
    
    return lhs.actualOrder < rhs.actualOrder
}

class Audio: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func FilePath() -> String{
        guard let _ = self.filename else{
            return ""
        }
        
        let filePath = self.filename!.FileLocation
        
        if filePath == "" {
            return ""
        }else{
            
            return filePath
        }
        
    }

    
    var actualOrder:Int{
        if let unwrappedOrder = order{
            return unwrappedOrder.intValue
        }else
        {
            return 0
        }
    }
    
    
}
