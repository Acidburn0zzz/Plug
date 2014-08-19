//
//  FriendsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsDataSource: NSObject, NSTableViewDataSource {
    var tableView: NSTableView?
    var filtering: Bool = false
    var tableContents: [Friend]?
    var filteredTableContents: [Friend]?
    
    // TODO: Sorting
    // TODO: Grouping
    func loadInitialValues() {
        HypeMachineAPI.Friends.AllFriends(
            {friends in
                self.tableContents = friends
                self.tableView?.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        
        if filtering {
            return filteredTableContents![row]
        } else {
            return tableContents![row]
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if tableContents == nil { return 0 }
        
        if filtering {
            return filteredTableContents!.count
        } else {
            return tableContents!.count
        }
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            filteredTableContents = tableContents!.filter {
                ($0.username =~ keywords) || ($0.fullName =~ keywords)
            }
        }
        tableView!.reloadData()
    }
}