//
//  AddContactViewReactor.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/09.
//

import Foundation
import ReactorKit

final class AddContactViewReactor: Reactor {
    enum Action {
        case cancel
        case done
        case editGivenName(String)
        case editFamilyName(String)
    }
    
    enum Mutation {
        case dismiss
        case editGivenName(String)
        case editFamilyName(String)
    }
    
    struct State {
        var isDismissed: Bool
        var addable: Bool
        var givenName: String
        var familyName: String
    }
    
    let provider: ServiceProviderType
    let initialState: State
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        self.initialState = State(
            isDismissed: false,
            addable: false,
            givenName: "",
            familyName: ""
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cancel:
            return .just(.dismiss)
            
        case .done:
            return self.provider.contactsService.addContact(for: self.createContact())
                .flatMap { Observable.just(.dismiss) }
            
        case .editGivenName(let givenName):
            return .just(.editGivenName(givenName))
            
        case .editFamilyName(let familyName):
            return .just(.editFamilyName(familyName))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .dismiss:
            newState.isDismissed = true
            
        case .editGivenName(let givenName):
            newState.givenName = givenName
            newState.addable = !newState.givenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !newState.familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
        case .editFamilyName(let familyName):
            newState.familyName = familyName
            newState.addable = !newState.givenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !newState.familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return newState
    }
    
    private func createContact() -> Contact {
        return Contact(fullName: "\(currentState.givenName) \(currentState.familyName)")
    }
    
}
