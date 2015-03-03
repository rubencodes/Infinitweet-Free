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

extension String {
    // This function converts from HTML colors (hex strings of the form '#ffffff') to UIColors
    mutating func hexStringToUIColor() -> UIColor {
        var cString:String = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (countElements(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}