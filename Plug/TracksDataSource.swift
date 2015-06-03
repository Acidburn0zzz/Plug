//
//  TracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 5/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class TracksDataSource: NSObject, NSTableViewDataSource {
    let tracksPerPage: Int = 20
    
    @IBOutlet var viewController: DataSourceViewController!
    
    var tracks: [HypeMachineAPI.Track]?
    var currentPage: Int = 1
    var loadingData: Bool = false
    var allTracksLoaded: Bool = false
    var nextPageParams: [String: AnyObject] {
        get {
            return [
                "page": currentPage + 1,
                "count": tracksPerPage,
            ]
        }
    }
    
    func loadInitialValues() {
        if loadingData { return }
        
        loadingData = true
        requestInitialValues()
    }
    
    func refresh() {
        loadInitialValues()
    }
    
    func requestInitialValues() {}
    
    func requestInitialValuesResponse(tracks: [HypeMachineAPI.Track]?, error: NSError?) {
        if error != nil {
            loadingError(error!)
            viewController.requestInitialValuesFinished()
            return
        }
        
        self.tracks = tracks
        viewController.tableView.reloadData()
        loadingData = false
        viewController.requestInitialValuesFinished()
    }
    
    func loadNextPage() {
        if loadingData { return }
        if allTracksLoaded { return }
        
        loadingData = true
        requestNextPage()
    }
    
    func requestNextPage() {}
    
    func requestNextPageResponse(newTracks: [HypeMachineAPI.Track]?, error: NSError?) {
        
        if error != nil {
            loadingError(error!)
            return
        }
        
        currentPage++
        allTracksLoaded = newTracks!.count < tracksPerPage
        
        if newTracks!.count > 0 {
            let rowIndexes = rowIndexesForNewTracks(newTracks!)
            self.tracks! = self.tracks! + newTracks!
            viewController.tableView.insertRowsAtIndexes(rowIndexes, withAnimation: .EffectNone)
        }
        
        loadingData = false
    }
    
    func loadingError(error: NSError) {
        Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
        println(error)
        loadingData = false
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return tracks!.filter({ $0.audioUnavailable == false })[row]
        } else {
            return tracks![row]
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tracks == nil { return 0 }
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return tracks!.filter({ $0.audioUnavailable == false }).count
        } else {
            return tracks!.count
        }
    }
    
    func trackForRow(row: Int) -> HypeMachineAPI.Track? {
        return tracks!.optionalAtIndex(row)
    }
    
    private func rowIndexesForNewTracks(newTracks: [HypeMachineAPI.Track]) -> NSIndexSet {
        let rowRange: NSRange = NSMakeRange(tracks!.count, newTracks.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
    
    func trackAfter(track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
        if let currentIndex = indexOfTrack(track) {
            let index = currentIndex + 1
            return trackAtIndex(index)
        } else {
            return nil
        }
    }
    
    func trackBefore(track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
        if let currentIndex = indexOfTrack(track) {
            let index = currentIndex - 1
            return trackAtIndex(index)
        } else {
            return nil
        }
    }
    
    func indexOfTrack(track: HypeMachineAPI.Track) -> Int? {
        if tracks == nil { return nil }
        
        return find(tracks!, track)
    }
    
    func trackAtIndex(index: Int) -> HypeMachineAPI.Track? {
        if tracks == nil { return nil }
        
        if index >= 0 && index <= tracks!.count - 1 {
            return tracks![index]
        } else {
            return nil
        }
    }
}