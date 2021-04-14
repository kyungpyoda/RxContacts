//
//  ContactsViewReactor.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/07.
//

import Foundation
import ReactorKit

final class ContactsViewReactor: Reactor {
    
    enum Action {
        case fetch(String)
        case add(Contact)
    }
    
    enum Mutation {
        case setSections([Contact], String)
    }
    
    struct State {
        var query: String?
        var sections: [ContactSection] = []
    }
    
    let initialState: State
    
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.initialState = State(
            sections: []
        )
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch(let query):
            return self.provider.contactsService.items
                .flatMapLatest{ Observable.just(Mutation.setSections($0, query)) }
        
        case .add(let newItem):
            return self.provider.contactsService.addContact(for: newItem)
                .flatMap({ _ in Observable.empty()})
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSections(items, query):
            let filtered = filter(items: items, with: query)
            let sections = splitToSections(with: filtered)
            newState.query = query
            newState.sections = sections
        }
        
        return newState
    }
    
    private func filter(items: [Contact], with query: String?) -> [Contact] {
        guard let query = query else { return [] }
        return items.filter { $0.fullName.hasPrefix(query) }
    }
    
    private func splitToSections(with items: [Contact]) -> [ContactSection] {
        var dict: [String: [Contact]] = [:]
        items.forEach {
            dict[$0.fullName.headerLetter] = (dict[$0.fullName.headerLetter] ?? []) + [$0]
        }
        return dict.sorted(by: ({ $0.key < $1.key })).map { section in
            ContactSection(header: section.key, items: section.value.sorted(by: { $0.fullName < $1.fullName }))
        }
    }
    
    func reactorForAddContact() -> AddContactViewReactor {
        return AddContactViewReactor(provider: self.provider)
    }
}
