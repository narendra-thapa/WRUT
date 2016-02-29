//
//  SelectPlayerViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-26.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SelectPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var startGameButton: UIBarButtonItem!
    
    var userName = NSData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.connectionManager.playerSelectDelegate = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.connectionManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("onlineListCell") as! OnlineTableCell
        
        cell.nameLabel.text = appDelegate.connectionManager.foundPeers[indexPath.row].displayName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.connectionManager.foundPeers[indexPath.row] as MCPeerID
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! OnlineTableCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        if let profileName = defaults.objectForKey("Name") as? String {
            if profileName.isEmpty {
                self.userName = NSKeyedArchiver.archivedDataWithRootObject(appDelegate.connectionManager.myPeerId.displayName)
                print("displayname: \(appDelegate.connectionManager.myPeerId.displayName)")
            } else {
                self.userName = NSKeyedArchiver.archivedDataWithRootObject(profileName)
                print("profilename: \(profileName)")
        }

        appDelegate.connectionManager.serviceBrowser.invitePeer(selectedPeer, toSession: appDelegate.connectionManager.session, withContext: self.userName, timeout: 20)
        }
    }
    
    
    @IBAction func startGameButtonPressed(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("chooseGame", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseGame" {
            //let detailVC = segue.destinationViewController as! ChooseGameViewController
            if var profileName = defaults.objectForKey("Name") as? String {
                if profileName.isEmpty {
                    profileName = appDelegate.connectionManager.myPeerId.displayName
                    print("displayname: \(appDelegate.connectionManager.myPeerId.displayName)")
                }
            appDelegate.connectionManager.updates.append(profileName + " is starting a Game")
            appDelegate.connectionManager.updateTimelineCollection(profileName + " is starting a Game")
            }
        }
    }
}

extension SelectPlayerViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfPlayers = appDelegate.connectionManager.connectedDevices.count
        if numberOfPlayers == 0 {
            startGameButton.enabled = false
        } else {
            startGameButton.enabled = true
        }
        return appDelegate.connectionManager.connectedDevices.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCollectionCell", forIndexPath: indexPath) as! PlayerCollectionCell
        cell.playerName.text = appDelegate.connectionManager.connectedDevices[indexPath.row].displayName
        return cell
    }
}

extension SelectPlayerViewController : CSMPlayerSelectDelegate {
    
    func foundPeer() {
        print("Found Peer")
        self.tableView.reloadData()
    }
    
    func lostPeer() {
        print("Lost Peer")
        self.tableView.reloadData()
    }
    
    
    func addPlayer() {
        print("Added Player")
        self.collectionView.reloadData()
    }
    
    func removePlayer() {
        print("Remove Player")
        self.collectionView.reloadData()
    }
    

    
//    func invitationWasReceived(fromPeer: String) {
//        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to play with you.", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
//            self.appDelegate.connectionManager.invitationHandlers(true, self.appDelegate.connectionManager.session)
//        }
//        
//        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
//            self.appDelegate.connectionManager.invitationHandlers(false, self.appDelegate.connectionManager.session)
//        }
//        
//        alert.addAction(acceptAction)
//        alert.addAction(declineAction)
//        
//        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
//    }
//    
//    func connectedWithPeer(peerID: MCPeerID) {
//        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
//            print("Connected now to peer \(peerID)")
//            
//            
//        }
//    }
    
}