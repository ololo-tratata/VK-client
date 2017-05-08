//
//  Localizator.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public class Localizator {
    
    private enum Key: String {
        
        case recordOnTheWall = "RecordOnTheWall"
        case networkUnreachable = "NetworkUnrechable"
        case connectError = "ConnectionError"
        case sendMessage = "SendMessage"
        case enterAText = "EnterAText"
        
        var comment: String {
            return ""
        }
    }
    
    public static let shared = Localizator()
    
    public var recordOnTheWall: String {
        return getString(key: .recordOnTheWall)
    }
    
    public var networkUnreachable: String {
        return getString(key: .networkUnreachable)
    }
    
    public var connectError: String {
        return getString(key: .connectError)
    }
    
    public var sendMessage: String {
        return getString(key: .sendMessage)
    }
    
    public var enterAText: String {
        return getString(key: .enterAText)
    }
    
    private init() {}
    
    private func getString(key: Key) -> String  {
        return NSLocalizedString(key.rawValue, comment: key.comment)
    }
}
