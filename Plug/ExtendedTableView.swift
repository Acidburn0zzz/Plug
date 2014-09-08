//
//  ExtendedTableView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ExtendedTableView: NSTableView {
    @IBInspectable var tracksMouseEnterExit: Bool = false
    
    var trackingArea: NSTrackingArea?
    var extendedDelegate: ExtendedTableViewDelegate?
    var mouseInsideRow: Int = -1
    
    var clipView: NSClipView {
        return superview as NSClipView
    }
    var scrollView: NSScrollView {
        return clipView.superview as NSScrollView
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if tracksMouseEnterExit {
            ensureTrackingArea()
            if find(trackingAreas as [NSTrackingArea], trackingArea!) == nil {
                addTrackingArea(trackingArea!)
            }
        }
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.MouseMoved, owner: self, userInfo: nil)
        }
    }
    
    override func viewDidMoveToWindow() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollViewDidStartScrolling:", name: NSScrollViewWillStartLiveScrollNotification, object: scrollView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollViewDidEndScrolling:", name: NSScrollViewDidEndLiveScrollNotification, object: scrollView)
    }

    override func mouseDown(theEvent: NSEvent!) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let clickedRow = rowAtPoint(localLocation)
        
        super.mouseDown(theEvent)
        
        if clickedRow == -1 { return }

        extendedDelegate?.tableView?(self, wasClicked: theEvent, atRow: clickedRow)
    }
    
    override func rightMouseDown(theEvent: NSEvent!) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let clickedRow = rowAtPoint(localLocation)
        
        super.rightMouseDown(theEvent)
        
        if clickedRow == -1 { return }
        
        extendedDelegate?.tableView?(self, wasRightClicked: theEvent, atRow: clickedRow)
    }
    
    override func mouseMoved(theEvent: NSEvent!) {
        super.mouseMoved(theEvent)
        
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let newMouseInsideRow = rowAtPoint(localLocation)
        
        if newMouseInsideRow != mouseInsideRow {
            if newMouseInsideRow != -1 {
                extendedDelegate?.tableView?(self, mouseEnteredRow: newMouseInsideRow)
            }
            if mouseInsideRow != -1 {
                extendedDelegate?.tableView?(self, mouseExitedRow: mouseInsideRow)
            }
            mouseInsideRow = newMouseInsideRow
        }
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        super.mouseExited(theEvent)
        
        if mouseInsideRow != -1 {
            extendedDelegate?.tableView?(self, mouseExitedRow: mouseInsideRow)
            mouseInsideRow = -1
        }
    }
    
    func scrollViewDidStartScrolling(notification: NSNotification) {
        mouseExited(nil)
    }
    
    func scrollViewDidEndScrolling(notification: NSNotification) {
        extendedDelegate?.didEndScrollingTableView?(self)
    }
}

@objc protocol ExtendedTableViewDelegate {
    
    optional func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int)
    optional func tableView(tableView: NSTableView, wasRightClicked theEvent: NSEvent, atRow row: Int)
    optional func tableView(tableView: NSTableView, mouseEnteredRow row: Int)
    optional func tableView(tableView: NSTableView, mouseExitedRow row: Int)
    optional func didEndScrollingTableView(tableView: NSTableView)
}
