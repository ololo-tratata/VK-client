//
//  Message.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/5/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public struct Message: DTOType {
    
    private enum Keys: String {
        case body = "body"
        case userId = "uid"
        case messageId = "mid"
        case date = "date"
    }

    public let userId: Int?
    public let body: String?
    public let messageId: Int?
    public let date: Int?
    
    public init?(json: [String: Any]) {
        guard
            let jsonUserId = json[Keys.userId.rawValue] as? Int,
            let jsonBody = json[Keys.body.rawValue] as? String
            else { return nil }
        
        self.messageId = json[Keys.messageId.rawValue] as? Int
        self.userId = jsonUserId
        self.body = jsonBody
        self.date = json[Keys.date.rawValue] as? Int
        
    }
    
}
