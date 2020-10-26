//
//  Station+Extension.swift
//  WBikes
//
//  Created by Diego on 20/10/2020.
//

import Foundation
import CoreData

extension Station {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createDate = Date()
    }
}
