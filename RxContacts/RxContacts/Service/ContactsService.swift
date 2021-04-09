//
//  ContactsService.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/08.
//

import Foundation
import Contacts
import RxSwift

enum ContactsEvent {
    case fetch
}

protocol ContactsServiceType {
    var provider: ServiceProviderType { get }
    func fetchContacts() -> Void
    func addContact(for newItem: Contact) -> Observable<Void>
    var items: BehaviorSubject<[Contact]> { get }
    var event: PublishSubject<ContactsEvent> { get }
}

final class ContactsService: ContactsServiceType {
    
    unowned let provider: ServiceProviderType
    private let store: CNContactStore
    let items = BehaviorSubject<[Contact]>(value: [])
    let event = PublishSubject<ContactsEvent>()
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        self.store = CNContactStore()
        self.store.requestAccess(for: .contacts) { [weak self] (available, error) in
            guard available else {
                print(error?.localizedDescription)
                return
            }
            self?.fetchContacts()
        }
    }
    
    func fetchContacts() {
        let fetchProperites: [CNKeyDescriptor] = [CNContactGivenNameKey, CNContactFamilyNameKey].map { $0 as CNKeyDescriptor }
        let request = CNContactFetchRequest(keysToFetch: fetchProperites)
        
        do {
            var result: [Contact] = []
            try store.enumerateContacts(with: request) { (contact, stop) in
                result.append(Contact(fullName: "\(contact.givenName) \(contact.familyName)"))
            }
            items.onNext(result)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addContact(for newItem: Contact) -> Observable<Void> {
        let newContact = CNMutableContact()
        let splitedName = newItem.fullName.split(separator: " ").map { String($0) }
        newContact.givenName = splitedName[0]
        newContact.familyName = (splitedName.count <= 1 ? "" : splitedName[1])
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
            fetchContacts()
        } catch {
            print(error.localizedDescription)
        }
        return .empty()
    }
}
