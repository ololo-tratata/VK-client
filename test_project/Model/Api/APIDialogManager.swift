//
//  APIDialogManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/13/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation
import CoreData

public class APIDialogManager: DialogManager {
    
    let moc = CoreDataManager.sharedInstance.managedObjectContext

    public func fetchDialog(count: Int, offset: Int, handler: @escaping ([Dialog]?, Error?) -> ()) {
        
        let route = Routes.getDialogs(count: count, offset: offset)

        NetworkService.shared.get(route: route, type: Dialog.self, callback: {
            result, error  in
            
            if result == nil {
                
                if self.entityIsEmpty() {
                    print("empty database")
                    //Database is empty
                    handler(nil, error)
                } else {
                    print("not empty database")
                    //конвертируем базу в диалоги и вызываем handler
                    
                }
                
                handler(nil, error)
            } else {
                if let resultData = result {
 //                   resultData.map { self.insertOrUpdate(dialog: $0) }
     
                    //проверить есть ли кеш, если нет -> конвертим диалоги в ентити и добавляем в базу
                    //          |
                    //+ нужно проверить есть ли такие уже в базе

                    do {
                        try self.moc.save()
                    } catch {
                        print("ERROR: erorr saving context")
                    }
                    
                    handler(result, nil)
                }
            }
        })
    }
    
    private func insertOrUpdate(dialog: Dialog) -> DialogEntity {
        
        let request = NSFetchRequest<DialogEntity>(entityName: "DialogEntity")
        
        var resultEntity = DialogEntity()
        
        let currentUser = PreferencesService.shared.userId!
        
        var userId: NSObject = NSNull()
        var chatId: NSObject = NSNull()
        
        if let id = dialog.userId {
            userId = NSNumber(value: id)
        } else {
            userId = NSNumber(integerLiteral: 0)
        }
        
        if let id = dialog.chatId {
            chatId = NSNumber(value: id)
        } else {
            chatId = NSNumber(integerLiteral: 0)
        }

            let predicate = NSPredicate(format: "accountId = %d && userId = %@ && chatId = %@", currentUser, userId, chatId)
            request.predicate = predicate
            do {
                let result = try moc.fetch(request) as [DialogEntity]
                if result.count > 0 {
                    
                    result[0].body = dialog.body
                    result[0].title = dialog.title
                    
                    return result[0]
                    
                } else {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: "DialogEntity", into: moc) as! DialogEntity
                    
                    entity.body = dialog.body
                    if let chatId = dialog.chatId {
                        entity.chatId = Int32(chatId)
                    }
                    if let userId = dialog.userId {
                        entity.userId = Int32(userId)
                    }
                    if let date = dialog.date {
                        entity.date = Int32(date)
                    }
                    if let currentUser = PreferencesService.shared.userId {
                        entity.accountId = Int32(currentUser)
                    }
                    entity.title = dialog.title
                    
                    resultEntity = entity
                    
                }
                
            } catch {
                print("error")
            }
        return resultEntity
        }
    
    private func entityIsEmpty() -> Bool {
        let request = NSFetchRequest<DialogEntity>(entityName: "DialogEntity")
    
        do {
            if let result = try moc.fetch(request) as Array? {
                return result.count == 0
            }
        } catch let error as NSError {
            print("Error: \(error.debugDescription)")
            return true
        }
    }
}
