//
//  Favorite+Extensions.swift
//  WBikes
//
//  Created by Diego on 20/10/2020.
//

import Foundation
import CoreData

extension City {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createDate = Date()
    }
}
