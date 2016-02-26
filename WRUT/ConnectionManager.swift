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
    
//    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String])
//    func colorChanged(manager : ConnectionManager, colorString: String)
//    func textReceived(manager : ConnectionManager, textReceived: String)
//    func drawingReceived(manager : ConnectionManager, drawingReceived: UIImage, instances: String)
    
}

protocol CSMPlayerSelectDelegate {
    
    func foundPeer()
    func lostPeer()
    func addPlayer()
    func removePlayer()
    
}

class ConnectionManager : NSObject {
    
    private let ConnectionServiceType = "naren-broadcast"
    
    var delegate : ConnectionServiceManagerDelegate?
    
    var playerSelectDelegate : CSMPlayerSelectDelegate?
    
    var foundPeers = [MCPeerID]()
    var connectedDevices = [MCPeerID]()
    var connectedList = [MCPeerID]()
    
    var invitationHandlers: ((Bool, MCSession)->Void) = { success, session in }
    
    var session: MCSession!
    var myPeerId: MCPeerID!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    override init() {
        
        super.init()
        
        myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
        //connectedDevices.append(myPeerId)
        
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
}


extension ConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        self.invitationHandlers = invitationHandler
        delegate?.invitationWasReceived(peerID.displayName)
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
            print("After-Connected \(self.connectedDevices)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.playerSelectDelegate?.addPlayer()
                if self.connectedDevices.count > 0 {
                    self.updatePlayerCollection() }
            })
            

        case MCSessionState.Connecting:
            print("Connecting to session: \(session)")
        default:
            print("Did not connect to session: \(session)")
            print("Lost connection to: \(peerID)")
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
            })
            
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data.length) bytes")
        print("\(peerID.displayName)")
        
        let myDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSDictionary
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

            print("\(instance, drawing)")
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











