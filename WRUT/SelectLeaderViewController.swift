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
    
        // Activate start button for selected peer
        self.appDelegate.connectionManager.activateStartButton(selectedPeer)
        
        self.goBackButton.enabled = true
        
        }
    
    @IBAction func goBackButtonPressed(sender: UIButton) {
        print("Go Back Button Pressed")
        
    }
    
    
    
}

