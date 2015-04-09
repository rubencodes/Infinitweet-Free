//
//  ViewController.swift
//  InfiniTweet
//
//  Created by Ruben on 1/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var iAd: ADBannerView!
    @IBOutlet weak var tweetView: UITextView!
    @IBOutlet var navItem: UINavigationItem!
    var clearButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?
    var keyboardIsShown : Bool?
    
    //cache of last known state
    let cache = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingPathComponent("lastKnownState.infinitweet")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "clearTextField")
        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareInfinitweet")
        self.navItem.setRightBarButtonItems([self.shareButton!, self.clearButton!], animated: false)
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
        //have we set the latest defaults?
        if !defaults.boolForKey(Infinitweet.currentDefaultKey()) {
            Infinitweet.setDefaults() //set the default text attributes in memory
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tweetView.delegate = self
        self.tweetView.textContainer.lineFragmentPadding = 0
        self.tweetView.allowsEditingTextAttributes = true
        
        //handle keyboard hiding/showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        
        self.keyboardIsShown = false
        
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
        //have we shown the tutorial?
        if !defaults.boolForKey("TutorialShown3") {
            self.beginTutorial() //if not, show it
        } else {
            //we have shown the tutorial, restore the last known state
            self.restoreLastKnownState()
            
            //then just focus on the textview
            self.tweetView.becomeFirstResponder()
        }
    }
    
    //restores the last state if there was one; else, just sets everything to default
    func restoreLastKnownState() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
        if let backup = defaults.valueForKey("Backup") as? String {
            self.tweetView.text = backup
        }
    }
    
    //something changed in the text view; update lastKnownState (and background)
    func textViewDidChange(textView: UITextView) {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
        
        defaults.setValue(textView.text, forKey: "Backup")
        defaults.synchronize()
    }
    
    //tutorial alers
    func beginTutorial() {
        var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
        
        var title : String?
        var message : String?
        var buttonTitle : String?
        
        title = "Tutorial"
        message = "Welcome to Infinitweet! To start, type some text! When you're ready to share, tap the Share icon on the top-right to post your Infinitweet to Twitter (or elsewhere)."
        buttonTitle = "I'm Ready"
        
        let tutorial = UIAlertController(title: title!,
            message: message!,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let OK = UIAlertAction(title: buttonTitle!,
            style: UIAlertActionStyle.Default,
            handler: {
                (action : UIAlertAction!) in
                
                defaults.setBool(true, forKey: "TutorialShown3")
                defaults.synchronize()
                self.tweetView.becomeFirstResponder()
        })
        
        tutorial.addAction(OK)
        
        self.presentViewController(tutorial, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tweetView.resignFirstResponder()
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillHide(notification : NSNotification) {
        var userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        var keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        var contentInsets = UIEdgeInsetsZero
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
        
        var viewFrame = self.tweetView.frame
        
        viewFrame.size.height += keyboardSize!.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        self.tweetView.frame = viewFrame
        UIView.commitAnimations()
        
        self.keyboardIsShown = false
    }
    
    func keyboardWillShow(notification : NSNotification) {
        if self.keyboardIsShown! {
            return
        }
        
        var userInfo = notification.userInfo as [NSObject : AnyObject]!
        
        var keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        self.tweetView.contentInset = contentInsets
        self.tweetView.scrollIndicatorInsets = contentInsets
        
        //buggy - either uncomment, and text < 1 screen is lost, or comment and carriage returns screw it up
        //        var viewFrame = self.tweetView.frame
        //        viewFrame.size.height -= keyboardSize!.height
        //
        //        UIView.beginAnimations(nil, context: nil)
        //        UIView.setAnimationBeginsFromCurrentState(true)
        //        self.tweetView.frame = viewFrame
        //        UIView.commitAnimations()
        
        self.keyboardIsShown = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //user wants to share the infinitweet
    func shareInfinitweet() {
        if self.tweetView.text != "" { //if text exists
            //get properties for new infinitweet
            let settings = Infinitweet.getDisplaySettings()
                        
            //create infinitweet with properties
            let infinitweet = Infinitweet(text: self.tweetView.text, font: settings.font, color: settings.color, background: settings.background, wordmarkHidden: settings.wordmark)
            
            //preload text on share
            var shareText : String?
            var defaults = NSUserDefaults(suiteName: "group.Codes.Ruben.Infinitweet")!
            let firstShare = !defaults.boolForKey("FirstShare")
            if firstShare {
                shareText = "Sharing from @InfinitweetApp for the first time!"
            } else {
                shareText = "via @InfinitweetApp"
            }
            
            //add objects to share
            var items = [AnyObject]()
            items.append(infinitweet.image)
            items.append(shareText!)
            
            //create share menu, handle iPad case
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if (UIDevice.currentDevice().model.hasPrefix("iPad")) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton!
            }
            
            //once finished sharing, display success message if completed
            activityViewController.completionHandler = {(activityType, completed:Bool) in
                if completed {
                    let alert = UIAlertController(title: "Success!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        delay(0.75, { () -> () in
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                alert.view.alpha = 0
                                }, completion: { (Bool) -> Void in
                                    alert.dismissViewControllerAnimated(false, completion: nil)
                            })
                        })
                    })
                }
            }
            
            //show the share menu
            self.presentViewController(activityViewController, animated: true, completion: nil)
        } else {
            let title = "Oops!"
            let message = "Please enter some text first, then we'll turn it into a shareable image."
            
            let error = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let OK = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {
                    (action : UIAlertAction!) in
                    self.tweetView.becomeFirstResponder()
                    return
            })
            
            error.addAction(OK)
            
            self.presentViewController(error, animated: true, completion: nil)
        }
    }
    
    func clearTextField() {
        self.tweetView.text = ""
        self.textViewDidChange(self.tweetView)
    }
}