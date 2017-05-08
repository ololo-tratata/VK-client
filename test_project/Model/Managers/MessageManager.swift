//
//  MessageManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation

protocol MessageManager {
    
    func fetchMessage(offset: Int, count: Int, reverse: Bool, id: MessageId, startMessageId: Int?, handler: @escaping (_ result: [Message]?, _ error: Error?) -> ())
    
    func sendMessage(peerId: MessageId, message: String, handler: @escaping (_ result: Bool, _ error: Error?) -> ())
    
}
