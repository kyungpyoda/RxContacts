//
//  UITableViewCell+Reusable.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/06.
//

import UIKit.UITableViewCell

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    static var reuseIdentifier: String { String(describing: Self.self) }
}
