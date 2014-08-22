//
//  HypeMachineAPI.swift
//  Plug
//
//  Created by Alex Marchant on 7/5/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

var apiBase = "https://api.hypem.com/v2"

struct HypeMachineAPI  {
    private static func GetJSON(url: String, parameters: Dictionary<String, String>?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    private static func GetHTML(url: String, parameters: Dictionary<String, String>?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    private static func PostJSON(url: String, parameters: Dictionary<String, String>?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
    
    private static func PostHTML(url: String, parameters: Dictionary<String, String>?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
 
    private static func deviceId() -> String {
        //        TODO fix this
        //        let username = username()
        //        return SSKeychain.passwordForService("Plug", account: username!)
        return "d7ee8670b0d5d73"
    }
    
    struct Tracks {
        static func Popular(subType: PopularPlaylistSubType, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/popular"
            let params = ["mode": subType.toRaw(), "page": "\(page)", "count": "\(count)", "hm_token": Authentication.GetToken()!]
            _getTracks(url, parameters: params, success: success, failure: failure)
        }
        
        static func Favorites(page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/favorites"
            let params = ["page": "\(page)", "count": "\(count)", "hm_token": Authentication.GetToken()!]
            _getTracks(url, parameters: params, success: success, failure: failure)
        }
        
        static func Latest(page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let params = ["page": "\(page)", "count": "\(count)", "hm_token": Authentication.GetToken()!]
            _getTracks(url, parameters: params, success: success, failure: failure)
        }
        
        static func Feed(subType: FeedPlaylistSubType, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/feed"
            let params = ["mode": subType.toRaw(), "page": "\(page)", "count": "\(count)", "hm_token": Authentication.GetToken()!]
            _getTracks(url, parameters: params, success: success, failure: failure)
        }
        
        static func Search(searchKeywords: String, subType: SearchPlaylistSubType, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let params = ["sort": subType.toRaw(), "q": searchKeywords, "page": "\(page)", "count": "\(count)", "hm_token": Authentication.GetToken()!]
            _getTracks(url, parameters: params, success: success, failure: failure)
        }
        
        static func ToggleLoved(track: Track, success: (loved: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/favorites?hm_token=\(Authentication.GetToken()!)"
            let params = ["type": "item", "val": track.id]
            HypeMachineAPI.PostHTML(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseData = responseObject as NSData
                    var html = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                    if html == "1" {
                        success(loved: true)
                    } else if html == "0" {
                        success(loved: false)
                    } else {
                        let error = AppError.UnexpectedApiResponseError()
                        NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected api response"])
                        failure(error: error)
                    }
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
        
        static func _getTracks(url: String, parameters: Dictionary<String, String>?, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            HypeMachineAPI.GetJSON(url, parameters: parameters, success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let responseArray = responseObject as NSArray
                var tracks = [Track]()
                for trackObject: AnyObject in responseArray {
                    let trackDictionary = trackObject as NSDictionary
                    tracks.append(Track(JSON: trackDictionary))
                }
                success(tracks: tracks)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                failure(error: error)
            })
        }
    }
    
    struct Playlists {
        static var trackCount: Int = 20
        
        static func Popular(subType: PopularPlaylistSubType, success: (playlist: PopularPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Popular(subType, page: 1, count: trackCount, success: {tracks in
                let playlist = PopularPlaylist(tracks: tracks, subType: subType)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Favorites(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Favorites(1, count: trackCount, success: {tracks in
                let playlist = FavoritesPlaylist(tracks: tracks)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Latest(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Latest(1, count: trackCount, success: {tracks in
                let playlist = LatestPlaylist(tracks: tracks)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Feed(subType: FeedPlaylistSubType, success: (playlist: FeedPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Feed(subType, page: 1, count: trackCount, success: {tracks in
                let playlist = FeedPlaylist(tracks: tracks, subType: subType)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Search(searchKeywords: String, subType: SearchPlaylistSubType, success: (playlist: SearchPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Search(searchKeywords, subType: subType,  page: 1, count: trackCount, success: {tracks in
                let playlist = SearchPlaylist(tracks: tracks, subType: subType, searchKeywords: searchKeywords)
                success(playlist: playlist)
            }, failure: failure)
        }
    }
    
    struct Blogs {
        static func AllBlogs(success: (blogs: [Blog])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/blogs"
            let params = ["hm_token": Authentication.GetToken()!]
            HypeMachineAPI.GetJSON(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseArray = responseObject as NSArray
                    var blogs = [Blog]()
                    for blogObject: AnyObject in responseArray {
                        let blogDictionary = blogObject as NSDictionary
                        blogs.append(Blog(JSON: blogDictionary))
                    }
                    success(blogs: blogs)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
    }
    
    struct Genres {
        static func AllGenres(success: (genres: [Genre])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tags"
            let params = ["hm_token": Authentication.GetToken()!]
            HypeMachineAPI.GetJSON(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseArray = responseObject as NSArray
                    var genres = [Genre]()
                    for genreObject: AnyObject in responseArray {
                        let genreDictionary = genreObject as NSDictionary
                        genres.append(Genre(JSON: genreDictionary))
                    }
                    success(genres: genres)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
    }

    struct Friends {
        static func AllFriends(success: (friends: [Friend])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/users/" + Authentication.GetUsername()! + "/friends"
            let params = ["hm_token": Authentication.GetToken()!]
            HypeMachineAPI.GetJSON(url, parameters: params,
                success: {operation, responseObject in
                    let responseArray = responseObject as NSArray
                    var friends = [Friend]()
                    for friendObject: AnyObject in responseArray {
                        let friendDictionary = friendObject as NSDictionary
                        friends.append(Friend(JSON: friendDictionary))
                    }
                    success(friends: friends)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
    }
    
    static func GetToken(username: String, password: String, success: (token: String)->(), failure: (error: NSError)->()) {
        let url = apiBase + "/get_token"
        let params = ["username": username, "password": password, "device_id": deviceId()]
        HypeMachineAPI.PostJSON(url, parameters: params,
            success: {operation, responseObject in
                let responseDictionary = responseObject as NSDictionary
                let token = responseDictionary["hm_token"] as String
                success(token: token)
            }, failure: {operation, error in
                println(error)
                println("")
                println(operation)
                println("")
                failure(error: error)
        })
    }
    
    static func TrackGraphFor(track: Track, success: (graph: TrackGraph)->(), failure: (error: NSError)->()) {
        let url = "http://hypem.com/inc/serve_track_graph.php"
        let params = ["id": track.id]
        HypeMachineAPI.GetHTML(url, parameters: params, success: {operation, responseObject in
            let responseData = responseObject as NSData
            var html = NSString(data: responseData, encoding: NSUTF8StringEncoding)
            let graph = TrackGraph(html: html, trackId: track.id)
            success(graph: graph)
        }, failure: {operation, error in
            failure(error: error)
        })
    }
}