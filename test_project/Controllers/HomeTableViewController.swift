//
//  HomeTableViewController.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/4/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import UIKit
import CoreData

public class HomeTableViewController: UITableViewController {
    
    let coreDataManager = CoreDataManager()
    // MARK: - Constants
    private static let fetchDialogCount = 10
    
    private enum Segues: String {
        case message = "ShowMessages"
        case loginView = "ShowLoginView"
    }
    
    // MARK: - Properties
    private var usersCollection = [User]()
    private var dialogs = [Dialog]()
    private var uid: MessageId = .none
    private var feedIsLoading = false
    private var lastDialog = false
    private var offset = 0
    private var users = [Int: User]()
    
    private let dialogManager = APIDialogManager()
    private let userManager = APIUserManager()
    
    
    @IBAction func logoutButton(_ sender: Any) {
        dialogs.removeAll()
        NetworkService.shared.logout()

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: Segues.loginView.rawValue, sender: self)
        }
    }
    
        // MARK: - Enums
    private enum CellIdentifiers: String {
        case dialogCell = "dialogCell"
    }
    
    public override func viewDidLoad() {
        self.refreshControl!.addTarget(self, action: #selector(HomeTableViewController.handleRefresh(refresh:)), for: UIControlEvents.valueChanged)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        self.dialogs.removeAll()
        if NetworkService.shared.isUserLoggedIn() {
            offset = 0
            
            collectDialogData()
            
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: Segues.loginView.rawValue, sender: self)
            }
        }
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.dialogCell.rawValue, for: indexPath) as! DialogTableViewCell
        let dialog = dialogs[indexPath.row]
        if dialog.title != " ... " {
            cell.dialogName.text = dialog.title
        } else {
            if let user = users[dialog.userId!] {
                if let firstName = user.firstName,
                    let lastName = user.lastName {
                    cell.dialogName.text = "\(firstName) \(lastName)"
                }
            }
        }
        
        if dialog.body == "" {
            cell.message.text = Localizator.shared.recordOnTheWall
        } else {
            cell.message.text = dialog.body
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialog = dialogs[indexPath.row]
        if dialog.chatId != nil {
            uid = .group(uid: dialog.chatId!)
        } else {
            uid = .user(uid: dialog.userId!)
        }
        self.performSegue(withIdentifier: Segues.message.rawValue, sender: nil)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.message.rawValue {
            let messageViewController = segue.destination as! MessageTableViewController
            messageViewController.id = uid
        }
    }

    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRow = tableView.numberOfRows(inSection: indexPath.section)
        if !feedIsLoading && indexPath.row == totalRow - 2 && indexPath.row == dialogs.count - 2 && dialogs.count >= 10 {
            self.feedIsLoading = true
            self.offset += 10
            
            collectDialogData()
        }
    }
    
    
    @objc private func handleRefresh(refresh: UIRefreshControl) {
        dialogs.removeAll()
        offset = 0
        
        collectDialogData()
    }
    
    private func collectDialogData() {
        dialogManager.fetchDialog(count: HomeTableViewController.fetchDialogCount, offset: offset, handler: {
            result, erorr in
            
            var userIds = Set<Int>()

            if let resultData = result {
                
                self.dialogs += resultData
                for dialog in self.dialogs {
                    guard let id = dialog.userId else { break }
                    userIds.insert(id)
                }
            } else {
                print(erorr as Any)
            }
            
            userIds.subtract([Int](self.users.keys))
            
            self.userManager.fetchUser(users: [Int](userIds), handler: {
                result, error in
                
                //DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                //}
                
                if let resultData = result {
                    for user in resultData {
                    self.users[user.id!] = user
                    }
                } else {
                    if let error = error {
                        switch error as! NetworkService.ResponseError {
                        case NetworkService.ResponseError.networkUnreachable:
                            DispatchQueue.main.async {
                                self.showAlertMessage(message: Localizator.shared.networkUnreachable,
                                                      title: Localizator.shared.connectError)
                            }
                        default: print(error)
                        }
                    }
                }
                self.feedIsLoading = false
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            })
        })
    }
}
