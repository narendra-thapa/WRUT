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
        
        appDelegate.restrictRotation = true
        
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
            self.imageSelectorLibrary()
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            print("Camera")
            self.imageSelectorCamera()
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imageSelectorLibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
  
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func imageSelectorCamera() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .Camera
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        //    profileImageView.contentMode = .ScaleAspectFill
       // let editImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let editImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.appDelegate.doodleImage = editImage!
        self.appDelegate.gameChoosen = "Doodle"
        self.performSegueWithIdentifier("drawingGame", sender: self)
    }
    
 //   func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {}
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
