//
//  APIMessageManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/16/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public class APIMessageManager: MessageManager {
    
    public func fetchMessage(offset: Int, count: Int, reverse: Bool, id: MessageId, startMessageId: Int?,  handler: @escaping ([Message]?, Error?) -> ()) {
    
        if let route = getRouteFromMessageId(id: id, count: count, reverse: reverse, startMessageId: startMessageId, offset: offset) {
            print(route)
            NetworkService.shared.get(route: route, type: Message.self, callback: {
                result, error  in
                
                if result == nil {
                    handler(nil, error)
                } else {
                    handler(result, nil)
                }
            })
        } else {
            print("ERROR: Cannot get route from messageId")
        }
    }
    
    public func sendMessage(peerId: MessageId, message: String, handler: @escaping (Bool, Error?) -> ()) {
    
        var route : Routes?
        
        switch peerId {
        case .user(let uid):
            route = .sendMessage(peerId: uid, message: message)
        case .group(let uid):
            let groupId = 2000000000 + uid
            route = .sendMessage(peerId: groupId, message: message)
        case .none:
            break
        }
        
        if let route = route {
            
            NetworkService.shared.send(route: route, callback: {
                result, error in
                
                if result {
                    handler(true, nil)
                } else {
                   handler(false, error)
                }
            })
        }
    }
    
    private func getRouteFromMessageId(id: MessageId, count: Int, reverse: Bool, startMessageId: Int?, offset: Int) -> Routes? {
        switch id {
        case .user(let uid):
            let route: Routes = .getMessages(count: count, reverse: reverse, userId: uid, startMessageId: startMessageId, offset: offset)
            return route
        case .group(let uid):
            let groupId = 2000000000 + uid
            let route: Routes = .getMessages(count: count, reverse: reverse, userId: groupId, startMessageId: startMessageId, offset: offset)
            return route
        case .none:
            print("no user or group id")
        }
        return nil
    }
    
}
