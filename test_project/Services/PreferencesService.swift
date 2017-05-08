//
//  PreferencesService.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/12/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

public class PreferencesService {
    
    private enum Keys: String {
        case expiresIn = "expires_in"
        case userId = "uid"
        case timeUpdate = "timeUpdate"
    }
    
    public static let shared = PreferencesService()
    
    private init() {}
    
    public var expiresTime: String? {
        get {
            if let returnValue = UserDefaults.standard.object(forKey: Keys.expiresIn.rawValue) as? String {
                return returnValue
            } else {
                return nil
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.expiresIn.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    public var userId: Int? {
        get {
            if let returnValue = UserDefaults.standard.object(forKey: Keys.userId.rawValue) as? Int {
                return returnValue
            } else {
                return nil
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userId.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    public var latestTimeUpdate: Date? {
        get {
            if let returnValue = UserDefaults.standard.object(forKey: Keys.timeUpdate.rawValue) as? Date {
                return returnValue
            } else {
                return nil
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.timeUpdate.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
