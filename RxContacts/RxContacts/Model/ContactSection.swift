//
//  ContactSection.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/06.
//

import Foundation
import RxDataSources

struct ContactSection {
    var header: String
    var items: [Contact]
}

extension ContactSection: SectionModelType {
    init(original: ContactSection, items: [Contact]) {
        self = original
        self.items = items
    }
}
