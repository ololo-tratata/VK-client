//
//  User.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/5/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public struct User: DTOType {
    
    private enum Keys: String {
        case firstName = "first_name"
        case lastName = "last_name"
        case userId = "uid"
    }
    
    public var id: Int?
    public var firstName: String?
    public var lastName : String?
    
    public init?(json: [String: Any]) {
        guard
            let jsonFirstName = json[Keys.firstName.rawValue] as? String,
            let jsonLastName = json[Keys.lastName.rawValue] as? String,
            let jsonId = json[Keys.userId.rawValue] as? Int
        else { return nil }
        
        self.id = jsonId
        self.firstName = jsonFirstName
        self.lastName = jsonLastName
        
    }
}
