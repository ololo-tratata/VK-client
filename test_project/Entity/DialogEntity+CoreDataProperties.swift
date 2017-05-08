//
//  DialogEntity+CoreDataProperties.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/19/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import Foundation
import CoreData


extension DialogEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DialogEntity> {
        return NSFetchRequest<DialogEntity>(entityName: "DialogEntity");
    }

    @NSManaged public var body: String?
    @NSManaged public var chatId: Int32
    @NSManaged public var title: String?
    @NSManaged public var userId: Int32
    @NSManaged public var date: Int32
    @NSManaged public var accountId: Int32

}
