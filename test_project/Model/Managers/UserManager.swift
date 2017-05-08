//
//  UserManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

protocol UserManager {
    
    func fetchUser(users: [Int], handler: @escaping (_ result: [User]?, _ error: Error?) -> ())
    
}
