//
//  ServiceProvider.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/08.
//

import Foundation

protocol ServiceProviderType: class {
    var contactsService: ContactsServiceType { get }
}

final class ServiceProvider: ServiceProviderType {
    lazy var contactsService: ContactsServiceType = ContactsService(provider: self)
}
