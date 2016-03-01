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
    var counter2 = 0
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // start timer and inform others
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        if appDelegate.drawingInstance {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        } else {
            let image = self.appDelegate.drawingReceived
            self.imageDrawView.image = image
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        // Do any additional setup after loading the view.
    }

    
    func timerAction() {
        ++counter
        timerLabel.text = "\(counter)"
        if (counter == 5) {
            trigger()
        }
    }
    
    func timerAction2() {
        ++counter2
        timerLabel.text = "\(counter2)"
        if (counter2 == 10) {
            trigger2()
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
        self.appDelegate.drawCollectionNewGameButton = true

        timer.invalidate()
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
        
    }
    
    func trigger2() {
        
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //ImageList.append(image)
        
        appDelegate.drawingList.append(image)
        UIGraphicsEndImageContext()
        
        let sendDrawing: NSDictionary = ["drawing":image, "first": "false"]
        self.appDelegate.connectionManager.sendImage(sendDrawing)
        
        timer.invalidate()
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
    }
    
}







