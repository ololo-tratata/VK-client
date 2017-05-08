//
//  ViewController.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/3/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import UIKit
import WebKit

public class AuthViewController: UIViewController, UIWebViewDelegate {

    let userManager = APIUserManager()
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: UIWebView!

    public override func viewWillAppear(_ animated: Bool) {
        webView.delegate = self
        let url = Routes.authorize.authorize
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.scheme == "vk\(Routes.AppConstant.appId.rawValue)" {
            let currentUrl = request.url?.absoluteString
            var userParam = [String: Any]()
            
            let textRange = currentUrl?.range(of: "#\(Routes.TokenKeys.accessToken.rawValue)")
            if textRange != nil {
                if let token = currentUrl?.components(separatedBy: "#") {
                    let parsedData = token[1].components(separatedBy: "&")
                
                    for element in parsedData {
                        let key = element.components(separatedBy: "=")
                        print(key)
                        userParam[key[0]] = key[1]
                    }
                    
                }
            }
            PreferencesService.shared.expiresTime = userParam[Routes.TokenKeys.expiresIn.rawValue] as? String
            do{
                try KeychainService.shared.saveToken(userParam[Routes.TokenKeys.accessToken.rawValue] as! String)
            } catch let error {
                print("ERROR: Values hasn't been saved in the Keychain. Error: \(error)")
            }
            
            userManager.fetchCurrentUser(handler: {
                result, erorr in
                
                if let resultData = result {
                    for user in resultData {
                        PreferencesService.shared.userId = user.id
                    }
                }
            })
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return false
        }
        return true
    }
    
}


