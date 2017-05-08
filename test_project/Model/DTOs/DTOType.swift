//
//  DTOType.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/5/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public protocol DTOType {
    
    init?(json: [String: Any])
    
}
