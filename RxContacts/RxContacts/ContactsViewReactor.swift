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
        case updateQuery(String?)
        case add(Contact)
    }
    
    enum Mutation {
        case setQuery(String?)
        case setSections
        case addNewItem(Contact)
    }
    
    struct State {
        var query: String?
        var items: [Contact] = []
        var sections: [ContactSection] = []
    }
    
    let initialState: State
    
    private let dummy: [Contact] = [
        Contact(fullName: "abc"),
        Contact(fullName: "apple"),
        Contact(fullName: "accept"),
        Contact(fullName: "aws"),
        Contact(fullName: "bbq"),
        Contact(fullName: "bbc"),
        Contact(fullName: "bad"),
        Contact(fullName: "cd"),
        Contact(fullName: "cable"),
        Contact(fullName: "홍경표"),
        Contact(fullName: "김애플"),
    ]
    
    init() {
        self.initialState = State(
            query: "",
            items: dummy,
            sections: []
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                Observable.just(Mutation.setQuery(query)),
                Observable.just(Mutation.setSections),
            ])
        case .add(let newItem):
            return Observable.concat([
                Observable.just(Mutation.addNewItem(newItem)),
                Observable.just(Mutation.setSections),
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .addNewItem(let newItem):
            newState.items.append(newItem)
        case .setQuery(let query):
            newState.query = query
        case .setSections:
            let filtered = filter(items: currentState.items, with: currentState.query)
            let sections = splitToSections(with: filtered)
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
}
