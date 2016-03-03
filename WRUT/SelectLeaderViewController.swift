//
//  SelectLeaderViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-29.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SelectLeaderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var goBackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.restrictRotation = true
        
        self.goBackButton.enabled = false
    }    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.connectionManager.connectedDevices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onlineListCell") as! OnlineTableCell
        cell.nameLabel.text = appDelegate.connectionManager.connectedDevices[indexPath.row].displayName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.connectionManager.connectedDevices[indexPath.row] as MCPeerID
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! OnlineTableCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        newLeaderSelected(selectedPeer)
    }
    
    func newLeaderSelected(selectedPeerID: MCPeerID) {
        let alert = UIAlertController(title: "", message: "Confirm", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            print("Selected")
            
            // Activate start button for selected peer
            self.appDelegate.connectionManager.activateStartButton(selectedPeerID)
            self.appDelegate.connectionManager.updateTimelineCollection("Boss: \(selectedPeerID.displayName)")
            self.appDelegate.iAmLeader = false

            self.performSegueWithIdentifier("goingToRootView", sender: self)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            print("Rejected")
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func goBackButtonPressed(sender: UIButton) {
        print("Go Back Button Pressed")
    }
    
}

