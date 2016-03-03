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
    
    var counter = 5
    var counter2 = 10
    var counter3 = 15
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.iAmLeader {
            appDelegate.drawingInstance = true
        }
        
        appDelegate.restrictRotation = false
        
        self.imageDrawView.image = nil
        
//        timerLabel.adjustsFontSizeToFitWidth = true
//        timerLabel.minimumScaleFactor = 0.2
        
        // start timer and inform others
        timer.invalidate()
        
        if appDelegate.gameChoosen == "Drawing" {
            
            if appDelegate.drawingInstance {
                self.imageDrawView.image = UIImage(named: "BlackBoard.jpg")
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            } else {
                let image = self.appDelegate.drawingReceived
                self.imageDrawView.image = image.image
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            }
        }
        
        if appDelegate.gameChoosen == "Doodle" {
            let image = self.appDelegate.doodleImage
            let width = self.appDelegate.doodleImage.size.width
            let height = self.appDelegate.doodleImage.size.height
            
            self.imageDrawView.frame.size.width = width
            self.imageDrawView.frame.size.height = height
            self.imageDrawView.image = image
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction3", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        
        
//        if appDelegate.drawingInstance {
//            if appDelegate.gameChoosen == "Doodle" {
//                let image = self.appDelegate.doodleImage
//                let width = self.appDelegate.doodleImage.size.width
//                let height = self.appDelegate.doodleImage.size.height
//                self.imageDrawView.frame.size.width = width
//                self.imageDrawView.frame.size.height = height
//                self.imageDrawView.image = image
//                let sendDrawing: NSDictionary = ["drawing":image, "first": "doodle", "sender":appDelegate.connectionManager.myPeerId.displayName]
//                self.appDelegate.connectionManager.sendImage(sendDrawing)
//                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction3", userInfo: nil, repeats: true)
//                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
//                
//            } else if appDelegate.gameChoosen == "Drawing" {
//                    if appDelegate.drawingInstance == true {
//                    self.imageDrawView.image = UIImage(named: "BlackBoard.jpg")
//                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
//                    NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
//                } else {
//                    let image = self.appDelegate.drawingReceived
//                    self.imageDrawView.image = image.image
//                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
//                    NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
//                }
//            }
//        } else {
//            let image = self.appDelegate.drawingReceived
//            self.imageDrawView.image = image.image
//            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
//            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
//        }
    
    }
    
    func timerAction() {
        
        timerLabel.text = "\(counter)"
        --counter
        if (counter == 0) {
            trigger()
        }
    }
    
    func timerAction2() {
        
        timerLabel.text = "\(counter2)"
        --counter2
        if (counter2 == 0) {
            trigger2()
        }
    }
    
    func timerAction3() {
        
        timerLabel.text = "\(counter3)"
        --counter3
        if (counter3 == 0) {
            trigger2()
        }
    }
    
    func trigger() {
        
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        let imageOfDrawing = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        print("First image size :\(imageOfDrawing.size)")
        
        self.appDelegate.drawingList.removeAll()
        let myDrawing = GameItem(image: imageOfDrawing, owner: appDelegate.connectionManager.myPeerId.displayName)
        self.appDelegate.drawingList.append(myDrawing)
        
    //    let newImage = imageOfDrawing!.lowestQualityJPEGNSData /// new line
        let sendImage = UIImage(data: imageOfDrawing!.lowestQualityJPEGNSData)
        
        print("First image size after compression:\(sendImage!.size)")
        
        let sendDrawing: NSDictionary = ["drawing":sendImage!, "first": "first", "sender" : appDelegate.connectionManager.myPeerId.displayName]
        self.appDelegate.connectionManager.sendImage(sendDrawing)

        timer.invalidate()
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
    }
    
    func trigger2() {
        
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        let imageOfDrawing = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        print("Second image size :\(imageOfDrawing.size)")
        
        self.appDelegate.drawingList.removeAll()
        self.appDelegate.drawingList.append(self.appDelegate.drawingReceived)
        
        let myDrawing = GameItem(image: imageOfDrawing, owner: appDelegate.connectionManager.myPeerId.displayName)
        self.appDelegate.drawingList.append(myDrawing)
        
   //     let newImage = imageOfDrawing!.lowestQualityJPEGNSData /// new line
        let sendImage = UIImage(data: imageOfDrawing!.lowestQualityJPEGNSData)
        print("Second image size after compression:\(sendImage!.size)")
        
        let sendDrawing: NSDictionary = ["drawing":sendImage!, "first": "second", "sender":appDelegate.connectionManager.myPeerId.displayName]
        self.appDelegate.connectionManager.sendImage(sendDrawing)
        
        timer.invalidate()
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
    }
    
}
