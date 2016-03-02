//
//  ChooseGameViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-28.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class ChooseGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    @IBAction func drawingGameChoosen(sender: UIButton) {
        self.appDelegate.drawingInstance = true
        self.appDelegate.gameChoosen = "Drawing"
        self.performSegueWithIdentifier("drawingGame", sender: self)
        appDelegate.connectionManager.updateTimelineCollection("\(appDelegate.connectionManager.myPeerId.displayName) has choosen 'Complete My Drawing'")
    }
    
    @IBAction func drawOverThePicture(sender: UIButton) {
        self.appDelegate.drawingInstance = true
        appDelegate.connectionManager.updateTimelineCollection("\(appDelegate.connectionManager.myPeerId.displayName) has choosen 'Doodle my Picture'")
        
        let alert = UIAlertController(title: "", message: "Select Photo Source", preferredStyle: UIAlertControllerStyle.Alert)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            print("Photo Library")
            self.imageSelector()
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            print("Camera")
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imageSelector() {
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .PhotoLibrary
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
    //    profileImageView.contentMode = .ScaleAspectFill
        self.appDelegate.doodleImage = image
        self.appDelegate.gameChoosen = "Doodle"
        self.performSegueWithIdentifier("drawingGame", sender: self)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
