//
//  News.swift
//  SportsRssReader
//
//  Created by Cunqi.X on 4/13/15.
//  Copyright (c) 2015 jl6467. All rights reserved.
//

import Foundation
import CoreData

class News: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var author: String?
    @NSManaged var desc: String
    @NSManaged var link: String
    @NSManaged var publicDate: String
    @NSManaged var category: String
    @NSManaged var creationDate: NSDate

}
