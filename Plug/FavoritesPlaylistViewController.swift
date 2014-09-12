//
//  FavoritesPlaylistViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FavoritesPlaylistViewController: BasePlaylistViewController {
    override var analyticsViewName: String {
        return "MainWindow/Favorites"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = FavoritesPlaylistDataSource(viewController: self)
    }
}
