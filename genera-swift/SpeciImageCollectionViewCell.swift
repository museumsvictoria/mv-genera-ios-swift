//
//  SpeciImageCollectionViewCell.swift
//  genera-swift
//
//  Created by Simon Sherrin on 16/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class SpeciImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageDescriton: UILabel!
    @IBOutlet weak var imageCredit: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollableImageView: ImageScrollView!
    var altText:String = ""
        {
        didSet{
    
                self.scrollableImageView.altText = altText
            
        }
    }
    
    
    var imageName:String = ""
    
    func updateCell() -> Void {
        if let imageDirectory:URL = Bundle.main.resourceURL?.appendingPathComponent("Images"){
            let imageSource = "\(imageDirectory.path)/\( self.imageName)"
            if let image:UIImage = UIImage(contentsOfFile: imageSource){
                //self.imageView.image = image
                self.scrollableImageView.displayImage = image
                self.scrollableImageView.altText = altText
            }
        }
    }

    
    
}
