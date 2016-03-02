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
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDrawView.image = nil
        
        // start timer and inform others
        timer.invalidate()
        
        
            

        if appDelegate.drawingInstance {
            
            if appDelegate.gameChoosen == "Doodle" {
                let image = self.appDelegate.doodleImage
                self.imageDrawView.image = image
                
                let sendDrawing: NSDictionary = ["drawing":image, "first": "doodle"]
                self.appDelegate.connectionManager.sendImage(sendDrawing)
                
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                
            } else if appDelegate.gameChoosen == "Drawing" {
            
            self.imageDrawView.image = UIImage(named: "BlackBoard.jpg")
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            
            }

            
        } else {
            
            
            
            let image = self.appDelegate.drawingReceived
            self.imageDrawView.image = image
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction2", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            }
        

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
    
    func trigger() {
        
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, 0.0)
        containerView.drawViewHierarchyInRect(containerView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        self.appDelegate.drawingList.removeAll()
        self.appDelegate.drawingList.append(image)
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

        self.appDelegate.drawingList.removeAll()
        self.appDelegate.drawingList.append(self.appDelegate.drawingReceived)
        self.appDelegate.drawingList.append(image)
        UIGraphicsEndImageContext()
        
        let sendDrawing: NSDictionary = ["drawing":image, "first": "false"]
        self.appDelegate.connectionManager.sendImage(sendDrawing)
        
        timer.invalidate()
        
        self.performSegueWithIdentifier("drawingCollection", sender: self)
    }
    
}







