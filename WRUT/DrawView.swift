//
//  DrawView.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-02-29.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var lines: [Line] = []
    var lastPoint: CGPoint!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastPoint = touches.first?.locationInView(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let newPoint = touches.first?.locationInView(self)
        lines.append(Line(start: lastPoint, end: newPoint!))
        lastPoint = newPoint
        
        self.setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        for line in lines {
            CGContextMoveToPoint(context, line.start.x, line.start.y)
            CGContextAddLineToPoint(context, line.end.x, line.end.y)
            
        }
        
        if appDelegate.gameChoosen == "Drawing" {
            CGContextSetRGBStrokeColor(context, 248/255.0, 248/255.0, 255/255.0, 0.8)
        } else {
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
        }
        
        if appDelegate.deviceModel == "iPhone" {
            CGContextSetLineWidth(context, 5)
        } else if appDelegate.deviceModel == "iPad" {
            CGContextSetLineWidth(context, 8)
        }
        
        CGContextSetLineCap(context, CGLineCap.Round)

        CGContextStrokePath(context)
    }

}