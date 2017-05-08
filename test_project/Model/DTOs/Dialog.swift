//
//  Dialog.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/5/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public struct Dialog: DTOType {
    
    private enum Keys: String {
        case body = "body"
        case userId = "uid"
        case chatId = "chat_id"
        case title = "title"
        case date = "date"
    }
    
    public var title : String?
    public var body: String?
    public var userId: Int?
    public var chatId: Int?
    public var date: Int?
    
    public init?(json: [String: Any]) {
        guard
            let jsonBody = json[Keys.body.rawValue] as? String,
            let jsonUserId = json[Keys.userId.rawValue] as? Int
            else { return nil }
        
        self.date = json[Keys.date.rawValue] as? Int
        self.chatId = json[Keys.chatId.rawValue] as? Int
        self.title = json[Keys.title.rawValue] as? String
        self.body = jsonBody
        self.userId = jsonUserId

    }
}
