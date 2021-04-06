//
//  String+headerLetter.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/06.
//

import Foundation

extension String {
    var headerLetter: String {
        guard let first = self.first,
              let value = UnicodeScalar(String(first))?.value else {
            return "#"
        }
        if value < 0xAC00 || value > 0xD7A3 {
            return String(first)
        } else {
            let t = UnicodeScalar(0x1100 + (value - 0xAC00) / 28 / 21)
            return String(t!)
        }
    }
}
