//
//  UIColor+fromString.swift
//  genera-swift
//
//  Created by Simon Sherrin on 5/08/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import Foundation
import UIKit
extension UIColor{
    
    func fromString(colorString:String) -> UIColor{
        var red:Float = 255.0;
        var green:Float = 255.0;
        var blue:Float = 255.0;
        var alpha:Float = 1.0;
        
        //assumption string comma separated list
        //either red,green,blue, alpha   e.g: 255,255,255,1.0
        
        //or  red, green, blue e.g 255,255,255 - alpha implicitly 1
            var colours:[String] = colorString.componentsSeparatedByString(",")
            if colours.count == 3{
                red = Float(colours[0]) ?? 0.0
                green = Float(colours[1]) ?? 0.0
                blue = Float(colours[2]) ?? 0.0
            }
            if colours.count == 4{
                red = Float(colours[0]) ?? 0.0
                green = Float(colours[1]) ?? 0.0
                blue = Float(colours[2]) ?? 0.0
                alpha = Float(colours[3]) ?? 0.0
            }
            //if colours

        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
}
