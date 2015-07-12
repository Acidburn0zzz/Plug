//
//  SearchHeaderViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class SearchHeaderViewController: NSViewController {
    var searchField: NSSearchField!

    override func loadView() {
        view = NSView()
        
        let background = BackgroundBorderView()
        background.background = true
        background.backgroundColor = NSColor.whiteColor()
        background.bottomBorder = true
        background.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        view.addSubview(background)
        background.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        searchField = NSSearchField()
        background.addSubview(searchField)
        searchField.snp_makeConstraints { make in
            make.centerY.equalTo(self.view)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
    }
}