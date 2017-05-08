//
//  DialogManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

protocol DialogManager {
    
    func fetchDialog(count: Int, offset: Int, handler: @escaping (_ result: [Dialog]?, _ error: Error?) -> ())
    
}
