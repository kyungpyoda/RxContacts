//
//  Contact.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/06.
//

import Foundation
import RxDataSources

struct ContactSection {
    var header: String
    var items: [Int]
}

extension ContactSection: SectionModelType {
    init(original: ContactSection, items: [Int]) {
        self = original
        self.items = items
    }
}
