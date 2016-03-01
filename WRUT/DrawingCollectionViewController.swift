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
    
    //var imagelist = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.connectionManager.drawingSheetDelegate = self

//    NSNotificationCenter.defaultCenter().addObserverForName("newDrawing", object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
//      //      self.imagelist = self.appDelegate.drawingList
//            self.collectionView.reloadData()
//        }
    }
}

extension DrawingCollectionViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return imagelist.count
        return self.appDelegate.drawingList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("drawingImageCell", forIndexPath: indexPath) as! DrawingCollectionViewCell
        //let image = imagelist[indexPath.row]
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
    //            NSNotificationCenter.defaultCenter().postNotificationName("newDrawing", object: nil)
                self.collectionView.reloadData()
            }
        }
    }
    
}
