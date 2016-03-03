//
//  SavedCollectionViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-03-01.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class SavedCollectionViewController: UIViewController, UICollectionViewDataSource {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var imageList = [GameItem]()
    var selectedRow : Int = 0
    var selectedSection : Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.restrictRotation = true
        
        if self.selectedSection == 0 {
            self.imageList = appDelegate.savedDrawingCollection[selectedRow] as! [GameItem]
        } else if self.selectedSection == 1 {
            self.imageList = appDelegate.savedDoodleCollection[selectedRow] as! [GameItem]
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("drawingImageCell", forIndexPath: indexPath) as! DrawingCollectionViewCell
        let image = self.imageList[indexPath.row]
        cell.imageView.image = image.image
        cell.ownerName.text = image.owner
        return cell
    }

}
