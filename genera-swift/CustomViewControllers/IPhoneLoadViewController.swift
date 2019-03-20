//
//  IPhoneLoadViewController.swift
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

class IPhoneLoadViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var SegueTest: UIButton!
    @IBOutlet weak var LoadingTextLabel: UILabel!

    
    @IBAction func ButtonPressed(_ sender: UIButton) {
           self.performSegue(withIdentifier: "openMainScreen", sender: sender)
    
    }
    
    var loadingComplete: Bool = false
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loadingComplete{
            setupFinished(nil)
        }
        else{
            
        //subscribe to Database updates
                        NotificationCenter.default.addObserver(self, selector: #selector(databasePercentComplete(_:)), name:NSNotification.Name(rawValue: NotificationType.DatabasePercentComplete), object: nil)
            
            progressBar.isHidden = false
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            LoadingTextLabel.isHidden = false
            
        }
    }
    
    @objc func databasePercentComplete(_ notification:Notification){
        
        if let percentage = (notification as NSNotification).userInfo?["percentage"] as? Float{
            
            if !progressBar.isHidden {
                
                progressBar.progress = percentage
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    

    func setupFinished(_ sender:AnyObject?){
        self.performSegue(withIdentifier: "openMainScreen", sender: sender)
        loadingComplete = true
    }
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
          if segue.identifier == "openMainScreen" {
            
         print("Found Main Screen")
            
        }
        
    }


}
