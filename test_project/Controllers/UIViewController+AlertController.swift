//
//  AlertController.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/20/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController  {
    public enum Action : String {
        case ok = "OK"
        case cancel = "Cancel"
    }
    
    func showAlertMessage(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Action.ok.rawValue, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendMessage(title: String, message: String, callback: @escaping ( _ result: String?) -> Void) {
    
        let alert = UIAlertController(title: title, message: Localizator.shared.enterAText, preferredStyle: .alert)
        alert.addTextField { (textField) in }
        alert.addAction(UIAlertAction(title: Action.ok.rawValue, style: .default, handler: { [alert] (_) in
            
                        if let textField = alert.textFields?[0]{
                            if textField.text != "" {
                                callback(textField.text)
                            }
            } else {
            self.showAlertMessage(message: Localizator.shared.enterAText, title: Localizator.shared.enterAText)
        }
    }))
        
    alert.addAction(UIAlertAction(title: Action.cancel.rawValue, style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
    
    
    }
        ///переделать
        



}
