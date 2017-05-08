//
//  Routes.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/6/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public enum MessageId {
    case user(uid: Int)
    case group(uid: Int)
    case none
}

public enum Routes {
    
    public enum TokenKeys: String {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case userId = "user_id"
    }
    
    public enum AppConstant: String {
        case appId = "5805360"
        case scope = "messages"
        case display = "mobile"
        case responseType = "token"
    }
    
    private static let baseURL = "https://api.vk.com/method/"
    private static let authBaseUrl = "https://oauth.vk.com/"
    
    case getMessages(count: Int, reverse: Bool, userId: Int, startMessageId : Int?, offset: Int)
    case getUsers(userId: [Int])
    case getCurrentUserId
    case getDialogs(count: Int, offset: Int)
    case sendMessage(peerId: Int, message: String)
    case authorize
    
    public var authorize: String {
        let stringUrl = Routes.authBaseUrl.appending(path.appending("?\(query)"))
        return stringUrl
    }
    
    public var request: String {
        let stringUrl = Routes.baseURL.appending(path.appending("?\(query)"))
        return stringUrl
    }
    
    public var path: String {
        switch self {
        case .getMessages:
            return "messages.getHistory"
        case .getUsers:
            return "users.get"
        case .getDialogs:
            return "messages.getDialogs"
        case .authorize :
            return "authorize"
        case .sendMessage:
            return "messages.send"
        case .getCurrentUserId:
            return "users.get"
        }
    }
    
    public var query: String {
            switch self {
            case .getMessages(let count, let reverse, let userId, let startMessageId, let offset):
                let reverse = reverse ? 1 : 0
                if let startMessageId = startMessageId {
                     return "offset=\(offset)&rev=\(reverse)&count=\(count)&user_id=\(userId)&start_message_id=\(startMessageId)&access_token=\(NetworkService.shared.token)"
                } else {
                    return "offset=\(offset)&count=\(count)&user_id=\(userId)&access_token=\(NetworkService.shared.token)"
                }
               
            case .getDialogs(let count, let offset):
                return "count=\(count)&offset=\(offset)&access_token=\(NetworkService.shared.token)"
                
            case .getUsers(let usersId):
                let users = usersId.map({"\($0)"}).joined(separator: ",")
                return "uids=\(users)&access_token=\(NetworkService.shared.token)"
                
            case .authorize:
                return "client_id=\(AppConstant.appId.rawValue)&scope=\(AppConstant.scope.rawValue)&redirect_uri=vk\(AppConstant.appId.rawValue)://authorize&display=\(AppConstant.display.rawValue)&response_type=\(AppConstant.responseType.rawValue)"
                
            case .sendMessage(let peerId, let message):
                return "peer_id=\(peerId)&message=\(message)&access_token=\(NetworkService.shared.token)&v=5.62"
            case .getCurrentUserId:
                return "access_token=\(NetworkService.shared.token)"
            }
    }
}
