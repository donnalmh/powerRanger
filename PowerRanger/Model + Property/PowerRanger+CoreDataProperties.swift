//
//  PowerRanger+CoreDataProperties.swift
//  PowerRanger
//
//  Created by Donna Samuel on 27/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData

extension PowerRanger {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PowerRanger> {
        return NSFetchRequest<PowerRanger>(entityName: "PowerRanger")
    }

    @NSManaged public var id: String?
    @NSManaged public var colourAsHex: String?
    @NSManaged public var pointX: CGFloat
    @NSManaged public var pointY: CGFloat
    @NSManaged public var isDeployed: Bool


}
