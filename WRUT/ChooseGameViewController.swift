//
//  ChooseGameViewController.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-28.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class ChooseGameViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func drawingGameChoosen(sender: UIButton) {
        self.performSegueWithIdentifier("drawingGame", sender: self)
        appDelegate.connectionManager.updateTimelineCollection("\(appDelegate.connectionManager.myPeerId.displayName) has choosen 'Complete My Drawing'")
    }

    
    @IBAction func storyGameChoosen(sender: UIButton) {
        self.performSegueWithIdentifier("storyGame", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
