//
//  NetworkService.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/5/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation


public class NetworkService {
    
    public static let shared = NetworkService()
    public private(set) var token = String()
    
    private init() {}
    
    public enum ResponseError: Error  {
        case invalidResponse
        case httpCode(code: Int)
        case endpointError
        case networkUnreachable
        case urlErrorDomain
        
        var errorDomain : String {
            switch self {
            case .urlErrorDomain:
                return "NSURLErrorDomain"
            default :
                return "Error"
            }
        }
    }
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    public func get<Type: DTOType>(route: Routes, type: Type.Type, callback: @escaping ( _ result: [Type]?, _ error: ResponseError?) -> Void) {
        
        isUserLoggedIn()
        let urlPath = route.request
        guard let endpoint = URL(string: urlPath) else {
            callback(nil, ResponseError.endpointError)
            return
        }
        //Save latest update time
        PreferencesService.shared.latestTimeUpdate = Date()

        var request = URLRequest(url: endpoint)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let error = error {
                let domainError = error as NSError
                
                if domainError.domain == ResponseError.urlErrorDomain.errorDomain {
                    callback(nil, ResponseError.networkUnreachable)
                } else {
                    callback(nil, ResponseError.invalidResponse)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse  {
                if response.statusCode != 200 {
                    callback(nil, ResponseError.httpCode(code: response.statusCode))
                    return
                }
            }
            
            guard let data = data else {
                callback(nil, ResponseError.invalidResponse)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else { return }
                print(json)
                if let result = NetworkService.parseJson(json: json, type: type) {
                    callback(result, nil)
                } else {
                    callback(nil, ResponseError.invalidResponse)
                }
            } catch {
                callback(nil, ResponseError.invalidResponse)
            }
        }.resume()
    }
    
    public func send(route: Routes, callback: @escaping ( _ result: Bool, _ error: Error?) -> Void) {
        
        let urlPath = route.request
        guard let endpoint = URL(string: urlPath) else {
            callback(false, ResponseError.endpointError)
            return
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = HTTPMethod.post.rawValue
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else { return }
                    print(json as Any)
                } catch let error {
                    callback(false, error)
                }
            }

            if let error = error {
                let domainError = error as NSError
                
                if domainError.domain == ResponseError.urlErrorDomain.errorDomain {
                    callback(false, ResponseError.networkUnreachable)
                } else {
                    callback(false, error)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse  {
                if response.statusCode != 200 {
                    callback(false, ResponseError.httpCode(code: response.statusCode))
                    return
                }
            }
        } .resume()
    }
    
    public func isUserLoggedIn() -> Bool {
        var storedKeychain: String?
        guard let expiresTime = PreferencesService.shared.expiresTime else { return false }
        
        do {
            storedKeychain = try KeychainService.shared.loadToken()
        }
        catch let error {
            print("ERROR: Values hasn't been loaded from the Keychain. Error: \(error)")
            return false
        }
        
        if let key = storedKeychain {
            if Int(expiresTime) != 0 {
                token = key
                return true
            }
        } else {
            return false
        }
        return false
    }
    
    public func logout() {
        
        do {
            try KeychainService.shared.deleteToken()
            PreferencesService.shared.userId = nil
            PreferencesService.shared.latestTimeUpdate = nil
        } catch let error {
            print(error)
        }
        
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                if cookie.domain.range(of: "vk.com") != nil {
                    storage.deleteCookie(cookie)
                }
            }
        }
    }
    
    private static func parseJson<Type: DTOType>(json: NSDictionary, type: Type.Type) -> [Type]? {
        var result = [Type]()
        if let jsonResponse = json["response"] as? [Any]{
            for data in jsonResponse {
                if let item = data as? [String: Any] {
                    if let value = Type(json: item) {
                        result.append(value)
                    } else {
                        return nil
                    }
                }
            }
        }
        return result
    }
}

