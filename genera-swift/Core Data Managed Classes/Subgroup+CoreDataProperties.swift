//
//  Subgroups+CoreDataProperties.swift
//  genera-swift
//
//  Created by Simon Sherrin on 9/10/2016.
//  Copyright © 2016 museumvictoria. All rights reserved.
//

import Foundation
import CoreData


extension Subgroup {


    @NSManaged  var label: String?
    @NSManaged  var sublabel: String?
    @NSManaged  var subgroupID: String?
    @NSManaged  var speci: NSSet?
    @NSManaged  var group: Group?

}

