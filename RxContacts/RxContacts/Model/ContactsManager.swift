//
//  ContactsManager.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/08.
//

import Foundation
import Contacts
import RxSwift

final class ContactsManager {
    
    private let store = CNContactStore()
    
    
    init() {
        store.requestAccess(for: .contacts) { (b, e) in
            print(b,e)
        }
    }
    
    func fetchContacts() -> Observable<[Contact]> {
        let fetchProperites: [CNKeyDescriptor] = [CNContactGivenNameKey, CNContactFamilyNameKey].map { $0 as CNKeyDescriptor }
        let request = CNContactFetchRequest(keysToFetch: fetchProperites)
        do {
            var result: [Contact] = []
            try store.enumerateContacts(with: request) { (contact, stop) in
                result.append(Contact(fullName: "\(contact.givenName) \(contact.familyName)"))
            }
            return .just(result)
        } catch {
            print(error.localizedDescription)
        }
        return .empty()
    }
    
    func addContact(for newItem: Contact) {
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
    }
    
}
