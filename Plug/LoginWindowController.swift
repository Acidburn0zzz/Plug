//
//  LoginWindowController.swift
//  Plug
//
//  Created by Alex Marchant on 10/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {
    var trafficButtons: TrafficButtons!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        trafficButtons = TrafficButtons(style: .Dark, groupIdentifier: "LoginWindow")
        trafficButtons.addButtonsToWindow(window!, origin: NSMakePoint(20, 20))
        trafficButtons.zoomButton.enabled = false
    }
}