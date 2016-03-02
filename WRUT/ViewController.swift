//
//  ViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-25.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    @IBOutlet weak var updatesMPCollectionView: UICollectionView!
    
    @IBOutlet weak var updatesViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var connectedProfilesFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var statusBarButton: UIBarButtonItem!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var inviteButton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let connectionService = ConnectionManager()
    var isAdvertising: Bool!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var profileName = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        connectionService.delegate = self
        appDelegate.connectionManager.delegate = self
        self.inviteButton.enabled = false
        isAdvertising = false
        
//        let numberOfPlayers = appDelegate.connectionManager.connectedList.count
//        if numberOfPlayers == 0 && isAdvertising == true && self.appDelegate.connectionManager.acceptance == true {
//            inviteButton.enabled = true
//            print("1st case")
//        } else if numberOfPlayers >= 0 && isAdvertising == true && self.appDelegate.connectionManager.acceptance == false {
//            inviteButton.enabled = true
//            print("2nd case")
//        } else {
//            inviteButton.enabled = false
//            print("3rd case \(numberOfPlayers) \(isAdvertising) \(self.appDelegate.connectionManager.acceptance)")
//        }
        
        appDelegate.restrictRotation = true
        
        if appDelegate.iAmLeader {
            self.inviteButton.enabled = true
        }
        
        if let userName = self.defaults.objectForKey("Name") as? String {
            self.profileName = userName
        }
        
        //self.updatesViewFlowLayout.estimatedItemSize = CGSize(width: 200, height: 20)
        
        self.connectedProfilesFlowLayout.estimatedItemSize = CGSize (width: 50, height: 20)
        
        self.statusView.layer.cornerRadius = self.statusView.frame.size.width / 2
    }
    
    override func viewWillAppear(animated: Bool) {
        self.inviteButton.enabled = false
        if appDelegate.iAmLeader {
            self.inviteButton.enabled = true
        }
    }
    
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
        print("Coming back to root view")
        appDelegate.drawingSourceViewController = true

    }
    
    @IBAction func toggleAdvertising(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "", message: "Change Visibility", preferredStyle: .ActionSheet)
        
        var actionTitle: String
        if isAdvertising == true {
            actionTitle = "Make me invisible to others"
        } else {
            actionTitle = "Make me visible to others"
        }
        
        let visibilityAction: UIAlertAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if self.isAdvertising == true {
                self.appDelegate.connectionManager.serviceAdvertiser.stopAdvertisingPeer()
                self.statusView.backgroundColor = UIColor.redColor()
                self.appDelegate.connectionManager.session.disconnect()
            } else {
                self.appDelegate.connectionManager.serviceAdvertiser.startAdvertisingPeer()
                self.statusView.backgroundColor = UIColor.greenColor()
            }
            self.isAdvertising = !self.isAdvertising
            
            if self.isAdvertising == true {
                self.inviteButton.enabled = true
                print("enabling")
            } else {
                self.inviteButton.enabled = false
                self.appDelegate.iAmLeader = false
                self.appDelegate.connectionManager.acceptance = false
                print("disabling")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(visibilityAction)
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.barButtonItem = statusBarButton
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if collectionView == self.collectionView {
        return appDelegate.connectionManager.connectedList.count
        }
        return appDelegate.connectionManager.updates.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("connectedCollectionCell", forIndexPath: indexPath) as! ConnectedCollectionCell
        cell.connectedPlayerCell.text = appDelegate.connectionManager.connectedList[indexPath.row].displayName
        return cell
        }
        let updateCell = collectionView.dequeueReusableCellWithReuseIdentifier("updateCollectionCell", forIndexPath: indexPath) as! UpdatesCollectionCell
        
        print(updatesMPCollectionView.frame.size.width)
        
        updateCell.updatesCellField.text = appDelegate.connectionManager.updates[indexPath.row]
        updateCell.frame.size.width = updatesMPCollectionView.frame.size.width - 30
        updateCell.frame.origin.x = updatesMPCollectionView.frame.origin.x
        
        return updateCell
    }
}

extension ViewController : UICollectionViewDelegate {
    
}

extension ViewController : ConnectionServiceManagerDelegate {
    
    func foundPeer() {
        print("Found Peer in main view controller")
    }
    
    func lostPeer() {
        print("Lost Peer in main view controller")
    }
    
    func updatePlayerList() {
        print("Updating connected List")
        self.collectionView.reloadData()
        self.updatesMPCollectionView.reloadData()
        let item = self.updatesMPCollectionView.numberOfItemsInSection(0) - 1
        let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
        self.updatesMPCollectionView?.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
    }
    
    func leftCurrentGroup() {
        print("Left current group")
        self.collectionView.reloadData()
        self.updatesMPCollectionView.reloadData()
    }
    
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to play with you.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.inviteButton.enabled = false
            self.appDelegate.connectionManager.invitationHandlers(true, self.appDelegate.connectionManager.session)
            self.appDelegate.connectionManager.acceptance = true
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.connectionManager.invitationHandlers(false, self.appDelegate.connectionManager.session)
            self.appDelegate.connectionManager.acceptance = false
        }
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            print("Connected now to peer \(peerID)")
        }
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
    
    func activateInviteButton() {
        self.inviteButton.enabled = true
    }
    
    
}
