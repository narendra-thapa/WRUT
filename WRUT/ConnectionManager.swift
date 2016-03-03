//
//  ConnectionManager.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-26.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectionServiceManagerDelegate {
    
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
    func updatePlayerList()
    func leftCurrentGroup()
    func loadDrawingView(gameItem: GameItem)
    func activateInviteButton()
    
//    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String])
//    func colorChanged(manager : ConnectionManager, colorString: String)
//    func textReceived(manager : ConnectionManager, textReceived: String)
    
    
}

protocol CSMPlayerSelectDelegate {
    
    func foundPeer()
    func lostPeer()
    func addPlayer()
    func removePlayer()
    
}

protocol CSMDrawingSheetDelegate {
    
    func drawingReceived(manager : ConnectionManager, drawingReceived: UIImage, instances: String, owner: String)
    func updateLabel(newUpdate: String)
    func loadDrawingView(gameItem: GameItem)
    
}

class ConnectionManager : NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private let ConnectionServiceType = "naren-broadcast"
    
    var delegate : ConnectionServiceManagerDelegate?
    
    var playerSelectDelegate : CSMPlayerSelectDelegate?
    
    var drawingSheetDelegate : CSMDrawingSheetDelegate?
    
    var acceptance: Bool!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var foundPeers = [MCPeerID]()
    var connectedDevices = [MCPeerID]()
    var connectedProfiles = [String]()
    var connectedList = [MCPeerID]()
    
    var updates = [String]()
    
    var invitationHandlers: ((Bool, MCSession)->Void) = { success, session in }
    
    var session: MCSession!
    var myPeerId: MCPeerID!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    override init() {
        
        super.init()
        myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        appDelegate.deviceModel = UIDevice.currentDevice().model
        
        if let profileName = defaults.objectForKey("Name") as? String {
            if profileName.isEmpty {
                print("No profile name set")
            } else {
                myPeerId = MCPeerID(displayName: profileName)
            }
        }
        //myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
        //connectedDevices.append(myPeerId)
        
        self.acceptance = false
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ConnectionServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ConnectionServiceType)
        
        self.session = MCSession(peer: myPeerId)
        self.session.delegate = self
        
        self.serviceAdvertiser.delegate = self
        //self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        //self.serviceAdvertiser.stopAdvertisingPeer()
        //self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func updatePlayerCollection() {
        if self.connectedDevices.count > 0 {
            connectedList.removeAll()
            connectedList.append(myPeerId)
            for MCPeerID in self.connectedDevices {
                connectedList.append(MCPeerID)
            }
            let sendDict: NSDictionary = ["playerList":connectedList]
            let myData = NSKeyedArchiver.archivedDataWithRootObject(sendDict)
            do {
                try self.session.sendData(myData, toPeers: self.connectedDevices,
                    withMode: MCSessionSendDataMode.Unreliable)
                print("Successfully sent")
            } catch {
                // do something.
                print("Bad quote!")
            }
        }
    }
    
    func updateTimelineCollection(update: String) {
        if self.connectedDevices.count > 0 {
            let sendDict: NSDictionary = ["updates":update]
            let myData = NSKeyedArchiver.archivedDataWithRootObject(sendDict)
            do {
                try self.session.sendData(myData, toPeers: self.connectedDevices,
                    withMode: MCSessionSendDataMode.Unreliable)
                print("Successfully sent")
            } catch {
                // do something.
                print("Bad quote!")
            }
        }
    }
    
    func sendImage(imageData: NSDictionary) {
        NSLog("%@", "sendImage: \(imageData)")
        let myData = NSKeyedArchiver.archivedDataWithRootObject(imageData)
        
        print("\(self.connectedDevices.count)")
        print("\(self.connectedDevices)")
        
        if self.connectedDevices.count > 0 {
            do {
                try self.session.sendData(myData, toPeers: self.connectedDevices,
                    withMode: MCSessionSendDataMode.Reliable)
            } catch {
                // do something.
                print("Bad quote!")
            }
        }
    }
    
    func activateStartButton(update: MCPeerID) {
        if self.connectedDevices.count > 0 {
            let newLeader : [MCPeerID] = [update]
            let sendDict: NSDictionary = ["activate":"activate"]
            let myData = NSKeyedArchiver.archivedDataWithRootObject(sendDict)
            do {
                try self.session.sendData(myData, toPeers: newLeader,
                    withMode: MCSessionSendDataMode.Unreliable)
                print("Successfully sent")
            } catch {
                // do something.
                print("Bad quote!")
            }
        }
    }
    
}


extension ConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        self.invitationHandlers = invitationHandler
        let inviteSenderName = NSKeyedUnarchiver.unarchiveObjectWithData(context!) as? String
        delegate?.invitationWasReceived(inviteSenderName!)
    }
}

extension ConnectionManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        foundPeers.append(peerID)
        self.playerSelectDelegate?.foundPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
        for (index, aPeer) in  EnumerateSequence(foundPeers){
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        self.playerSelectDelegate?.lostPeer()
    }
}

extension ConnectionManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
            print("Connected to session: \(session)")
            print("Before-Connected \(self.connectedDevices)")
            self.connectedDevices.append(peerID)
            
            self.updates.append("Added to group: \(peerID.displayName)")
            
            if let profileName = self.defaults.objectForKey("Name") as? String {
                print("profileName \(profileName)")
                self.connectedProfiles.append(profileName)
            } else {
                self.connectedProfiles.append(myPeerId.displayName)
            }
            print("After-Connected \(self.connectedDevices)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.playerSelectDelegate?.addPlayer()
                if self.connectedDevices.count > 0 {
                    self.updatePlayerCollection() }
            })
            

        case MCSessionState.Connecting:
            print("Connecting to session: \(session)")
            let profileName = self.defaults.objectForKey("Name") as? String
            print("profileName \(profileName)")
            
        default:
            print("Did not connect to session: \(session)")
            print("Lost connection to: \(peerID)")
            
            self.updates.append("Left group: \(peerID.displayName)")
            
            print("Before-Disconnected \(self.connectedDevices)")
            for (index, aPeer) in  EnumerateSequence(connectedDevices){
                if aPeer == peerID {
                    connectedDevices.removeAtIndex(index)
                    break
                }
            }
            print("After-Disconnected \(self.connectedDevices)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.playerSelectDelegate?.removePlayer()
                
                if self.connectedDevices.count > 0 {
                    self.updatePlayerCollection() }
                else {
                    self.connectedList.removeAll()
                    self.delegate?.leftCurrentGroup()
                }
                let profileName = self.defaults.objectForKey("Name") as? String
                print("profileName \(profileName)")
            })
            
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data.length) bytes")
        print("\(peerID.displayName)")
        
        if let myDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
            print(myDictionary)
            
            if let connectedPlayers = myDictionary["playerList"] as? [MCPeerID] {
                connectedList.removeAll()
                connectedList = connectedPlayers
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.updatePlayerList()
                    print("Updated List received")
                })
                
            } else if let drawing = myDictionary["drawing"] as? UIImage {
                let instance = myDictionary["first"] as? String
                let sender = myDictionary["sender"] as? String
                let gameItemReceived = GameItem(image: drawing, owner: sender!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    print("\(instance, drawing, sender)")
                    if instance! == "first" {
                        self.appDelegate.gameChoosen = "Drawing"
                        
                        if self.appDelegate.drawingSourceViewController  {
                            self.delegate?.loadDrawingView(gameItemReceived)
                        } else {
                            self.drawingSheetDelegate?.loadDrawingView(gameItemReceived)
                        }
                    } else if instance! == "doodle" {
                        self.appDelegate.gameChoosen = "Doodle"
                        
                        self.appDelegate.doodleImage = drawing
                        
                        if self.appDelegate.drawingSourceViewController  {
                            self.delegate?.loadDrawingView(gameItemReceived)
                        } else {
                            self.drawingSheetDelegate?.loadDrawingView(gameItemReceived)
                        }
                        
                    } else {
                        self.drawingSheetDelegate?.drawingReceived(self, drawingReceived: drawing, instances: instance!, owner: sender!)
                    }
                })
                
            } else if let newUpdate = myDictionary["updates"] as? String {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updates.append(newUpdate)
                    self.delegate?.updatePlayerList()
                    self.drawingSheetDelegate?.updateLabel(newUpdate)
                })
                
            } else if let newUpdate = myDictionary["activate"] as? String {
                if newUpdate == "activate" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.appDelegate.iAmLeader = true
                        self.delegate?.activateInviteButton()
                    })
                }
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    
}











