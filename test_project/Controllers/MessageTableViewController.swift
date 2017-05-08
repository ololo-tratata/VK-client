//
//  MessageTableViewController.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/10/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import UIKit

public class MessageTableViewController: UITableViewController {

    private enum CellIdentifiers: String {
        case messageCell = "messageCell"
    }
    
    public var id: MessageId = .none
    private var fetchMessageCount = 10
    private var reverse: Bool = false
    private var messages = [Message]()
    private var feedIsLoading = false
    private var lastDialog = false
    private var messageRoute: Routes?
    private var users = [Int: User]()
    private var startMessageId = 0
    
    private let messageManager = APIMessageManager()
    private let userManager = APIUserManager()
    
    lazy private var refresh = UIRefreshControl()
    
    @IBAction func sendMessageButton(_ sender: Any) {
        sendMessage(title: Localizator.shared.sendMessage, message: Localizator.shared.enterAText, callback:{
            [ weak self ]result in
            
            guard let controller = self else {
                return
            }
            
            if let inputText = result {
            
                controller.messageManager.sendMessage(peerId: controller.id, message: inputText, handler: {
                result, error in
                
                    if let error = error {
                        switch error as! NetworkService.ResponseError {
                            case NetworkService.ResponseError.networkUnreachable:
                            controller.showAlertMessage(message: Localizator.shared.networkUnreachable, title: Localizator.shared.connectError)
                        default: print(error)
                        }
                    }
                })
            }
        })
    }

    public override func viewWillAppear(_ animated: Bool) {
        self.messages.removeAll()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        refreshControl?.addTarget(self, action: #selector(MessageTableViewController.handleRefresh(refresh:)), for: UIControlEvents.valueChanged)
        
        reverse = false

        collectMessageData(lastMessageId: nil, offset: 0)
        
        tableView.reloadData()
    }
    
    func handleRefresh(refresh: UIRefreshControl) {
        
        if let latestId = messages[0].messageId {
            reverse = false
            self.collectMessageData(lastMessageId: latestId, offset: 1)
        }
    }

    // MARK: - Table view data source

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.messageCell.rawValue, for: indexPath) as! MessageTableViewCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.body
        
        if let user = users[message.userId!] {
            if let firstName = user.firstName,
                let lastName = user.lastName {
                cell.userNameLabel.text = "\(firstName) \(lastName)"
            }
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRow = tableView.numberOfRows(inSection: indexPath.section)
        
        if !feedIsLoading && indexPath.row == totalRow - 2 && indexPath.row == messages.count - 2 && messages.count >= 10 {
            self.feedIsLoading = true
            
            if let latestId = messages[messages.count - 1].messageId {
                reverse = true
                let offset = -1
                collectMessageData(lastMessageId: latestId, offset: offset)
            }
        }
    }

    // MARK: - Function
    
    private func collectMessageData(lastMessageId: Int?, offset: Int) {
        
        messageManager.fetchMessage(offset: offset, count: fetchMessageCount, reverse: reverse, id: id, startMessageId: lastMessageId,  handler: {
            [weak self] result, error in
            
            guard let controller = self else {
                return
            }
            
            var userIds = Set<Int>()

            if offset == 1 {
                if let resultData = result {
                    for i in resultData {
                        controller.messages.insert(i, at: 0)
                    }
                }
            } else {
                if let resultData = result {
                    if controller.reverse {
                        let reversedResult = resultData.reversed()
                        controller.messages += reversedResult
                    } else {
                        controller.messages += resultData
                    }
                    for message in controller.messages {
                        guard let id = message.userId else { break }
                        userIds.insert(id)
                    }
                } else {
                    if let error = error {
                        switch error as! NetworkService.ResponseError {
                        case NetworkService.ResponseError.networkUnreachable:
                            controller.showAlertMessage(message: Localizator.shared.networkUnreachable, title: Localizator.shared.connectError)
                        default: print(error)
                        }
                    }
                    controller.feedIsLoading = false
                    return
                }
            }

            controller.refreshControl?.endRefreshing()
            
            userIds.subtract([Int](controller.users.keys))
            
            controller.userManager.fetchUser(users: [Int](userIds), handler: {
                result, error in
                
                if let resultData = result {
                    for user in resultData {
                        controller.users[user.id!] = user
                    }
                } else {
                    print(error as Any)
                }
                controller.feedIsLoading = false
                
                DispatchQueue.main.async{
                    controller.tableView.reloadData()
                }
            })
        })
    }
}

