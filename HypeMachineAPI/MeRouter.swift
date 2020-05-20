import Foundation
import Alamofire

extension Router {
	public enum Me: URLRequestConvertible {
		case favorites(params: Parameters?)
		case toggleTrackFavorite(id: String, params: Parameters?)
		case toggleBlogFavorite(id: Int, params: Parameters?)
		case toggleUserFavorite(id: String, params: Parameters?)
		case playlistNames
		case showPlaylist(id: Int, params: Parameters?)
		case postHistory(id: String, position: Int, params: Parameters?)
		case friends(params: Parameters?)
		case feed(params: Parameters?)

		var method: HTTPMethod {
			switch self {
			case .favorites:
				return .get
			case .toggleTrackFavorite:
				return .post
			case .toggleBlogFavorite:
				return .post
			case .toggleUserFavorite:
				return .post
			case .playlistNames:
				return .get
			case .showPlaylist:
				return .get
			case .postHistory:
				return .post
			case .friends:
				return .get
			case .feed:
				return .get
			}
		}

		var path: String {
			switch self {
			case .favorites:
				return "/me/favorites"
			case .toggleTrackFavorite:
				return "/me/favorites"
			case .toggleBlogFavorite:
				return "/me/favorites"
			case .toggleUserFavorite:
				return "/me/favorites"
			case .playlistNames:
				return "/me/playlist_names"
			case let .showPlaylist(id, _):
				return "/me/playlists/\(id)"
			case .postHistory:
				return "/me/history"
			case .friends:
				return "/me/friends"
			case .feed:
				return "/me/feed"
			}
		}

		var params: Parameters? {
			switch self {
			case let .favorites(optionalParams):
				return optionalParams
			case let .toggleTrackFavorite(id, optionalParams):
				return ["val": id, "type": "item"].merge(optionalParams)
			case let .toggleBlogFavorite(id, optionalParams):
				return ["val": id, "type": "site"].merge(optionalParams)
			case let .toggleUserFavorite(id, optionalParams):
				return ["val": id, "type": "user"].merge(optionalParams)
			case .playlistNames:
				return nil
			case let .showPlaylist(_, optionalParams):
				return optionalParams
			case let .postHistory(id, position, optionalParams):
				return ["type": "listen", "itemid": id, "pos": position].merge(optionalParams)
			case let .friends(optionalParams):
				return optionalParams
			case let .feed(optionalParams):
				return optionalParams
			}
		}

		public func asURLRequest() throws -> URLRequest {
			try Router.generateURLRequest(method: method, path: path, params: params)
		}
	}
}