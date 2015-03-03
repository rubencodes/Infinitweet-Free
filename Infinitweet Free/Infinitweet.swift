//
//  Infinitweet.swift
//  InfiniTweet
//
//  Created by Ruben on 3/1/15.
//  Copyright (c) 2015 Ruben. All rights reserved.
//

import Foundation
import UIKit

class Infinitweet {
    var image : UIImage
    
    init(text : String, font : UIFont, color : UIColor, background : UIColor, padding : CGFloat) {
        //set text properties
        let textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        
        //set initial image attempt properties
        var width = 200
        var imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        
        //prepare wordmark for later
        let wordmark = "Infinitweet" as NSString
        let wordmarkAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0), NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.5)]
        var wordmarkSize = wordmark.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: wordmarkAttributes, context: nil)
        
        //avoid infinite loops
        var repeatLimitHit = false
        var lastWidth = 0.0 as CGFloat
        var lastHeight = 0.0 as CGFloat
        var repeatCount = 0
        
        //if image is too narrow, make it wider
        while imageSize.width < (imageSize.height+wordmarkSize.height+padding)*1.9 && repeatLimitHit == false {
            //if width is really small, set to minimum width and exit loop
            if imageSize.width < CGFloat(width) {
                imageSize = CGRectMake(0, 0, (imageSize.height+wordmarkSize.height+padding)*2, imageSize.height)
                break
            }
            
            width += 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth && imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
        }
        
        //avoid infinite loops
        repeatLimitHit = false
        lastWidth = 0.0 as CGFloat
        lastHeight = 0.0 as CGFloat
        repeatCount = 0
        
        //if image is too long, make it narrower
        while imageSize.width > (imageSize.height+wordmarkSize.height+padding)*2.1 && repeatLimitHit == false {
            width -= 10
            imageSize = (text as NSString).boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
            
            //if the dimensions haven't changed, make sure we haven't hit an infinite loop
            if imageSize.width == lastWidth && imageSize.height == lastHeight {
                repeatCount++
                if repeatCount >= 200 {
                    repeatLimitHit = true
                }
            } else { //reset counter once we've seen something new
                repeatCount = 0
            }
            
            lastWidth = imageSize.width
            lastHeight = imageSize.height
        }
        
        //round widths and add padding
        let adjustedWidth = max(CGFloat(ceilf(Float(imageSize.width))), CGFloat(ceilf(Float(wordmarkSize.width))))
        let adjustedHeight = CGFloat(ceilf(Float(imageSize.height))) + CGFloat(ceilf(Float(wordmarkSize.height))) + padding
        let outerRectSize = CGSizeMake(adjustedWidth + 2*padding, adjustedHeight + 2*padding)
        
        //generate image
        UIGraphicsBeginImageContextWithOptions(outerRectSize, true, 0.0)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        image.drawInRect(CGRectMake(0,0,outerRectSize.width,outerRectSize.height))
        
        background.set()
        let outerRect = CGRectMake(0, 0, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), outerRect)
        
        //draw text
        let innerRect = CGRectMake(padding, padding, adjustedWidth, adjustedHeight)
        text.drawInRect(CGRectIntegral(innerRect), withAttributes: textAttributes)
        
        //draw infinitweet wordmark
        let wordmarkOrigin = CGPoint(x: adjustedWidth-(wordmarkSize.width-padding), y: adjustedHeight-(wordmarkSize.height-padding))
        let wordmarkRect = CGRectMake(wordmarkOrigin.x, wordmarkOrigin.y, wordmarkSize.width, wordmarkSize.height)
        wordmark.drawInRect(wordmarkRect, withAttributes: wordmarkAttributes)
        
        //save new image
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
}