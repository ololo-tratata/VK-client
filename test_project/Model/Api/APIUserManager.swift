//
//  APIUserManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public class APIUserManager: UserManager {
    
    public func fetchUser(users: [Int], handler: @escaping ([User]?, Error?) -> ()) {
        var usersCollection = [User]()
        let route = Routes.getUsers(userId: users)
        
        NetworkService.shared.get(route: route, type: User.self, callback: {
            result, error  in
            
            if result == nil {
                handler(nil, error)
            } else {
                if let resultData = result {
                    usersCollection = usersCollection + resultData
                    handler(usersCollection, nil)
                }
            }
        })
    }
    
    public func fetchCurrentUser(handler: @escaping ([User]?, Error?) -> ()) {
        
        let route = Routes.getCurrentUserId
        
        NetworkService.shared.get(route: route, type: User.self, callback: {
            result, error  in
            
            if result == nil {
                handler(nil, error)
            } else {
                if let resultData = result {
                    handler(resultData, nil)
                    print(resultData)
                }
            }
        })
    }
}
