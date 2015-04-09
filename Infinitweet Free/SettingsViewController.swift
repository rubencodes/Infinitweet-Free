//
//  SettingsViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/5/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    override func viewDidLoad() {
        var title = "Infinitweet Pro"
        var message = "Sorry, to access these cool special features, or to Infinitweet text from any app on your phone, you have to purchase Infinitweet Pro on the App Store!"
        
        var tutorial = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        var OK = UIAlertAction(title: "Take Me!",
            style: UIAlertActionStyle.Default,
            handler: { (action : UIAlertAction!) in
                UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/app/infinitweet-pro/id955118051?mt=8")!)
                return
        })
        
        var Cancel = UIAlertAction(title: "No Thanks",
            style: UIAlertActionStyle.Default,
            handler: nil)
        
        tutorial.addAction(OK)
        tutorial.addAction(Cancel)
        
        self.presentViewController(tutorial, animated: true, completion: nil)
    }
}