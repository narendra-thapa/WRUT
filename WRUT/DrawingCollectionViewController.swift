//
//  DrawingCollectionViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-29.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class DrawingCollectionViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newLeaderSelect: UIButton!
    
    @IBOutlet weak var updateLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.newLeaderSelect.enabled = false
        
        appDelegate.restrictRotation = true
    
        appDelegate.connectionManager.drawingSheetDelegate = self
        
//        if appDelegate.drawCollectionNewGameButton {
//            self.newLeaderSelect.enabled = true
//        }
       
        if appDelegate.iAmLeader {
            self.newLeaderSelect.enabled = true
        }
        
        appDelegate.drawingSourceViewController = false

    }
    
    @IBAction func saveDrawingCollection(sender: UIButton) {
        
        if appDelegate.gameChoosen == "Doodle" {
            self.appDelegate.savedDoodleCollection.append(self.appDelegate.drawingList)
        } else if appDelegate.gameChoosen == "Drawing" {
            self.appDelegate.savedDrawingCollection.append(self.appDelegate.drawingList)
        }
    }
    
    
    @IBAction func NewLeaderSelect(sender: UIButton) {
        // turn off newleader button off
    }
    
    @IBAction func startNewGame(sender: UIButton) {
        // turn off newGame button off
    }
}

extension DrawingCollectionViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appDelegate.drawingList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("drawingImageCell", forIndexPath: indexPath) as! DrawingCollectionViewCell
        let image = self.appDelegate.drawingList[indexPath.row]
        cell.imageView.image = image
        return cell
    }
}

extension DrawingCollectionViewController : CSMDrawingSheetDelegate {
    
    func drawingReceived(manager : ConnectionManager, drawingReceived: UIImage, instances: String) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            print("drawing received: \(drawingReceived)")
            if instances == "false" {
                self.appDelegate.drawingList.append(drawingReceived)
                self.collectionView.reloadData()
            }
        }
    }
    
    func updateLabel(newUpdate: String) {
        self.updateLabel.text = newUpdate
    }
    
    func loadDrawingView(drawingReceived: UIImage) {
        self.appDelegate.drawingInstance = false
        self.appDelegate.drawingReceived = drawingReceived
        self.appDelegate.drawingList.append(drawingReceived)
        let DVC = storyboard?.instantiateViewControllerWithIdentifier("drawingView") as? DrawingViewController
        presentViewController(DVC!, animated: true) { () -> Void in
            print("Okay till here")
        }
    }
    
}
