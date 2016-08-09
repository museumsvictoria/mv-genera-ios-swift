//
//  ImageScrollView.swift
//  CollectionViewTest
//
//  Created by Simon Sherrin on 10/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    
   var imageView: UIImageView!
   var altText: String = ""
    {
        didSet{
            if !altText.isEmpty{
                if imageView != nil{
                imageView.accessibilityLabel = "Image showing \(altText)"
                imageView.isAccessibilityElement = true
                }
            }
        }
        
    }
   weak var displayImage:UIImage?
        {
        didSet{
            
            self.setup()

        }
        
    }
    var index:Int = 0

    deinit{
        self.delegate = nil
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()

        print("imageView:\(imageView?.frame.size)")

        
    }
    
    
    
    func setMaxMinZoomScalesForCurrentBounds() -> Void{
        
        let scrollViewFrame = self.frame
        let scaleWidth = scrollViewFrame.size.width / self.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        self.minimumZoomScale = minScale;

        print("MaxMinScale:\(self.minimumZoomScale), \(self.maximumZoomScale)")
        if self.minimumZoomScale > self.maximumZoomScale{ //if image is smaller - issue on iPad Pro
            self.maximumZoomScale = self.minimumZoomScale
            
        }
        
    }
    
    func maximumContentOffset() -> CGPoint
    {
        let contentSize = self.contentSize;
        let boundsSize = self.bounds.size;
        return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
       
    }
    
    func minimumContentOffset() -> CGPoint
    {
        return CGPointZero;
        
    }
    
    func restoreCenterPoint(oldCenter:CGPoint, oldScale:CGFloat) -> Void{
        self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale));
        // Step 2: restore center point, first making sure it is within the allowable range.
        
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter = convertPoint(oldCenter, fromView: imageView)
        // 2b: calculate the content offset that would yield that center point
        var offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
            boundsCenter.y - self.bounds.size.height / 2.0);
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset = self.maximumContentOffset()
        let minOffset = self.minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x));
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y));
        self.contentOffset = offset;
        print("Restore CenterPoint")
    }
    
    func pointToCenterAfterRotation() -> CGPoint{
        //   CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        //   return [self convertPoint:boundsCenter toView:imageView];
        
        let boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        return convertPoint(boundsCenter, toView : imageView)

    }
    
    func scaleToRestoreAfterRotation() -> CGFloat{
        var contentScale = self.zoomScale
        if (contentScale <= self.minimumZoomScale + CGFloat(FLT_EPSILON)){
            contentScale = 0
        }
        return contentScale
        
 
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        displayImage = UIImage(named: "placeholder.jpg")!
        self.delegate = self
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        displayImage = UIImage(named: "placeholder.jpg")!
        self.delegate = self
        

    }
    
    func setup(){
        
        if imageView != nil{
            
            imageView.removeFromSuperview()
            imageView = nil
            self.zoomScale = 1.0
        }
        if (displayImage != nil){
        imageView = UIImageView(image: displayImage)
        imageView!.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:displayImage!.size)
            if !altText.isEmpty{
                imageView.accessibilityLabel = "Image showing \(altText)"
                imageView.isAccessibilityElement = true
            }
        // 2
        self.addSubview(imageView!)
        self.contentSize = displayImage!.size
        
        // 3
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        
        // 4
        self.setMaxMinZoomScalesForCurrentBounds()
        
       self.zoomScale = self.minimumZoomScale;
        
        // 6
      // centerScrollViewContents() // getting called twice due to zoomScale set
        print ("setup")
        }
    }
    
    
    
    
    //testing different approach
    func centerScrollViewContents() {
        let boundsSize = self.bounds.size
       // self.setMaxMinZoomScalesForCurrentBounds()
        var contentsFrame = imageView!.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView!.frame = contentsFrame
        print("Center Scroll View Contents: \(contentsFrame)")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        //doubleTapParent?.ImageScrollViewDoubleTapped(recognizer)
        
        if (self.zoomScale == self.maximumZoomScale){
            self.setMaxMinZoomScalesForCurrentBounds()
            self.setZoomScale(self.minimumZoomScale, animated: true)
            
        }else
        {
            let tapPoint = recognizer.locationInView(imageView)
            let viewSize = self.bounds.size
            let w = viewSize.width / self.maximumZoomScale
            let h = viewSize.height / self.maximumZoomScale
            let x = tapPoint.x - (w / 2.0)
            let y = tapPoint.y - (h / 2.0)
            
            let zoomRect = CGRectMake(x, y, w, h);
            
            self.zoomToRect(zoomRect, animated: true)
        }
      
    }
    
}


protocol ImageScrollViewDelegate {
    func ImageScrollViewDoubleTapped(recogniser: UITapGestureRecognizer)
}