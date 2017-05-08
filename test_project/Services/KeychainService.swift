//
//  KeychainService.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/4/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import UIKit
import Security

public enum KeychainError: Error {
    case invalidInput
    case operationUnimplemented
    case invalidParam
    case memoryAllocationFailure
    case trustResultsUnavailable
    case authFailed
    case duplicateItem
    case itemNotFound
    case serverInteractionNotAllowed
    case decodeError
    case unknown(Int)
}

class KeychainService: NSObject {
    
    //Singleton
    public static let shared = KeychainService()
    private override init() {
        super.init()
    }
    
    // Identifiers
    private static let serviceIdentifier = "MyService"
    private static let userAccount = "authenticatedUser"
    private static let accessGroup = "MyService"
    
    // Arguments for the keychain queries
    private let kSecClassValue = String(kSecClass)
    private let kSecAttrAccountValue = String(kSecAttrAccount)
    private let kSecValueDataValue = String(kSecValueData)
    private let kSecClassGenericPasswordValue = String(kSecClassGenericPassword)
    private let kSecAttrServiceValue = String(kSecAttrService)
    private let kSecMatchLimitValue = String(kSecMatchLimit)
    private let kSecReturnDataValue = String(kSecReturnData)
    private let kSecMatchLimitOneValue = String(kSecMatchLimitOne)
    private let kSecAttrAccessibleValue = String(kSecAttrAccessible)

    public func saveToken(_ token: String) throws {
       try self.save(KeychainService.serviceIdentifier, itemValue: token as String)
    }
    
    public func loadToken() throws -> String? {
        let token = try self.load(service: KeychainService.serviceIdentifier)
        return token as! String?
    }
    
    public func deleteToken() throws {
        try self.delete()
    }
    
    private func delete() throws {
        let query = [
            (kSecClassValue): kSecClassGenericPassword
        ]
        let resultCode = SecItemDelete(query as CFDictionary)
        
        if let err = mapResultCode(result: resultCode){
            throw err
        }
    }
    
    private func save(_ itemKey: String, itemValue: String) throws {
        let valueData = itemValue.data(using: String.Encoding.utf8)
        
        let queryAdd: [String: AnyObject] = [
            kSecClassValue : kSecClassGenericPassword,
            kSecAttrAccountValue: itemKey as AnyObject,
            kSecValueDataValue: valueData as AnyObject,
            kSecAttrAccessibleValue: kSecAttrAccessibleWhenUnlocked
        ]
        
        let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if let err = mapResultCode(result: resultCode) {
            throw err
        }
    }
    
     private func load(service: String) throws -> AnyObject? {
        let queryLoad: [String: AnyObject] = [
            kSecClassValue: kSecClassGenericPassword,
            kSecAttrAccountValue: service as AnyObject,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitOneValue: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        if let err = mapResultCode(result: resultCodeLoad) {
            throw err
        }
        
        if let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as? String {
            return keyValue as AnyObject?
        } else {
            print("Error parsing keychain result: \(resultCodeLoad)")
            return nil
        }
    }
    
    private func mapResultCode(result:OSStatus) -> KeychainError? {
        switch result {
        case 0:
            return nil
        case -4:
            return .operationUnimplemented
        case -50:
            return .invalidParam
        case -108:
            return .memoryAllocationFailure
        case -25291:
            return .trustResultsUnavailable
        case -25293:
            return .authFailed
        case -25299:
            return .duplicateItem
        case -25300:
            return .itemNotFound
        case -25308:
            return .serverInteractionNotAllowed
        case -26275:
            return .decodeError
        default:
            return .unknown(result.hashValue)
        }
    }
}
