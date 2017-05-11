//
//  AudioTableViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 18/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData
import CoreAudio
import AVFoundation

class AudioTableViewController: UITableViewController, AVAudioPlayerDelegate {

    var audiolist: [Audio] = [Audio]()   
    
    var reuseIdentifier = "AudioCell"
    var player: AVAudioPlayer?
    var activeTrack:UIImageView?
    var inactiveTrack:UIImageView?
    var fileCellLookup: [String: Int] = [String: Int]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        inactiveTrack = UIImageView(image: UIImage(named: "AudioTrackInactive.png"), highlightedImage: UIImage(named:"AudioTrackHighlightInactive.png"))
        activeTrack = UIImageView(image: UIImage(named: "AudioTrackActive.png"), highlightedImage: UIImage(named: "AudioTrackHighlightActive.png"))
        //active track animation
    
        var activeTrackNormalAnimation: [UIImage] = [UIImage]()
        var activeTrackHighlightedAnimation: [UIImage] = [UIImage]()
        
        if let firstImage = UIImage(named: "AudioTrackActive.png"){
            
            activeTrackNormalAnimation.append(firstImage)
        }
        if let firstHighlightImage = UIImage(named: "AudioTrackHighlightActive.png"){
            activeTrackHighlightedAnimation.append(firstHighlightImage)
        }
        
        for countValue in 1...2{
            if let nextActiveImage = UIImage(named: "AudioTrackActive\(countValue).png"){
                activeTrackNormalAnimation.append(nextActiveImage)
            }
            if let nextHightlightImage = UIImage(named: "AudioTrackHighlightActive\(countValue).png"){
                activeTrackHighlightedAnimation.append(nextHightlightImage)
            }
            
        }
       
        activeTrack?.animationImages = activeTrackNormalAnimation
        activeTrack?.highlightedAnimationImages = activeTrackHighlightedAnimation

        self.tableView.rowHeight = 75
        
        if #available(iOS 9.0, *) {
            self.tableView.cellLayoutMarginsFollowReadableWidth = false
        } else {
            // Fallback on earlier versions
            //No Change needs to be made..
        }
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return audiolist.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        //Get the Audio file
        let cellAudio = self.audiolist[(indexPath as NSIndexPath).row]
       cell.textLabel?.attributedText = cellAudio.audioDescription?.AttributedStringNoIndent()
       // cell.textLabel?.text = cellAudio.audioDescription
        cell.detailTextLabel?.text = cellAudio.credit
        cell.imageView?.image = inactiveTrack?.image
        cell.imageView?.highlightedImage = inactiveTrack?.image
        
        
        

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedAudio: Audio = self.audiolist[(indexPath as NSIndexPath).row]
        if let audioLocation = selectedAudio.filename?.FileLocation{
            
            self.fileCellLookup[URL(fileURLWithPath:audioLocation).absoluteString] = (indexPath as NSIndexPath).row //so we can update the cell when the audio stops playing.
           let playing = playAudio(selectedAudio)
            if let activeCell = tableView.cellForRow(at: indexPath) {
                if playing{
                    activeCell.imageView?.image = activeTrack?.image;
                    activeCell.imageView?.highlightedImage = activeTrack?.highlightedImage;
                    activeCell.imageView?.animationImages = activeTrack?.animationImages;
                    activeCell.imageView?.highlightedAnimationImages = activeTrack?.highlightedAnimationImages;
                    activeCell.imageView?.animationDuration = 1;
                    activeCell.imageView?.startAnimating()
                }
            }
        }
    }

    // MARK: - Audio Player 
    
    func playAudio(_ selectedAudio: Audio) -> Bool {
        var returnValue: Bool = true
        let audioFileLocation  = selectedAudio.filename?.FileLocation
        
        if audioFileLocation == nil {return false} // audio not found, the player, it does nothing.
        
        if self.player != nil{
            //existing player in place set delegate to nil before creating new player
            self.player?.delegate = nil
        }
        do{
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioFileLocation!))
            if let actualPlayer = self.player
            {
                actualPlayer.delegate = self
                actualPlayer.prepareToPlay()
                actualPlayer.play()
            }
        }
        catch
        {
            //The player doesn't load
            returnValue = false
        }
        return returnValue
    }
    
    //MARK: Audio Player Delegate Functions
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       
        if let tmpURL = player.url{
            if let cellRow = self.fileCellLookup[tmpURL.absoluteString]{
                if let finishedCell = self.tableView.cellForRow(at: IndexPath(row: cellRow, section: 0))
                {
                    finishedCell.imageView?.stopAnimating()
                    finishedCell.imageView?.image = self.inactiveTrack?.image
                    finishedCell.imageView?.highlightedImage = self.inactiveTrack?.highlightedImage
                    finishedCell.setNeedsDisplay()
                    
                }
            }
            
        }
        
        /*NSURL *tmpURL = passedplayer.url;
        NSLog(@"Player URL:%@",[tmpURL lastPathComponent]);
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:(NSIndexPath *)[self.fileRowLocations objectForKey:[tmpURL relativePath]]];
        [cell.imageView stopAnimating];
        cell.imageView.image = inactiveTrack.image;
        cell.imageView.highlightedImage = inactiveTrack.highlightedImage;
        [cell setNeedsDisplay];
        */
        
        
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
