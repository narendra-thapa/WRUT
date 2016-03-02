//
//  SavedListViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-03-01.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class SavedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var drawingTableView: UITableView!
    @IBOutlet weak var doodleTableView: UITableView!
    
    var selectedItem : Int = 0
    var selectedTable : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.restrictRotation = true
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == drawingTableView {
        return appDelegate.savedDrawingCollection.count
        }
        return appDelegate.savedDoodleCollection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == drawingTableView {
            let cell = drawingTableView.dequeueReusableCellWithIdentifier("savedDrawingListCell") as! SavedListTableViewCell
            let number = indexPath.row + 1
            cell.DrawingCollectionNumber.text = "Drawing Game: \(number)"
            return cell
        }
        let cell = doodleTableView.dequeueReusableCellWithIdentifier("savedDrawingListCell") as! SavedListTableViewCell
        let number = indexPath.row + 1
        cell.DrawingCollectionNumber.text = "Doodling Game: \(number)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == drawingTableView {
            self.selectedItem = (drawingTableView.indexPathForSelectedRow?.row)!
            self.selectedTable = 0
        } else {
            self.selectedItem = (doodleTableView.indexPathForSelectedRow?.row)!
            self.selectedTable = 1
        }
        self.performSegueWithIdentifier("showCollection", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollection" {
            let viewController = segue.destinationViewController as! SavedCollectionViewController
            
            viewController.selectedRow = self.selectedItem
            viewController.selectedSection = self.selectedTable
            
        }
    }
    
    
    
}
