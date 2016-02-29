//
//  DrawingViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-29.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageDrawView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    var counter = 0
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // start timer and inform others
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerAction() {
        ++counter
        timerLabel.text = "\(counter)"
        if (counter == 5) {
            trigger()
        }
    }
    
    func trigger() {
        
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //ImageList.append(image)
        
        appDelegate.drawingList.append(image)
        UIGraphicsEndImageContext()
        
        let sendDrawing: NSDictionary = ["drawing":image, "first": "true"]
        self.appDelegate.connectionManager.sendImage(sendDrawing)
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
        
    }

}


extension DrawingViewController : CSMDrawingSheetDelegate {
    
    func drawingReceived(manager : ConnectionManager, drawingReceived: UIImage, instances: String) {
    NSOperationQueue.mainQueue().addOperationWithBlock {
    print("drawing received: \(drawingReceived)")
    
    if instances == "true" {
    self.imageDrawView.image = drawingReceived
    
    self.appDelegate.drawingList.append(drawingReceived)
    NSNotificationCenter.defaultCenter().postNotificationName("newDrawing", object: nil)
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "secondTimerAction", userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
    
    } else {
    self.appDelegate.drawingList.append(drawingReceived)
            }
        }
    }
    
}





