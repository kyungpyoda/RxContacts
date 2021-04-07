//
//  ContactsViewModel.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/07.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class ContactsViewModel {
    //input
    var tap = PublishRelay<Void>()
    var query = BehaviorSubject<String>(value: "")
    
    //output
    var sectionedContacts: Driver<[ContactSection]>
    
    var model = BehaviorSubject<[Contact]>(value: [])
    var disposeBag = DisposeBag()
    
    init() {
        model.onNext(Dummy.data) // TODO: fetch CNContact
        
        sectionedContacts = Observable.combineLatest(model, query)
            .flatMapLatest { (temp: (model: [Contact], query: String)) -> Observable<[ContactSection]> in
                let filtered = temp.model.filter { $0.fullName.hasPrefix(temp.query) }
                var dict: [String: [Contact]] = [:]
                filtered.forEach {
                    dict[$0.fullName.headerLetter] = (dict[$0.fullName.headerLetter] ?? []) + [$0]
                }
                return .just(
                    dict.sorted(by: ({ $0.key < $1.key })).map { section in
                        ContactSection(header: section.key, items: section.value.sorted(by: { $0.fullName < $1.fullName }))
                    }
                )
            }
            .asDriver(onErrorJustReturn: [])
        
        self.tap
            .withLatestFrom(model)
            .map {
                var nextModel = $0
                nextModel.append(Contact(fullName: "피자"))
                return nextModel
            }
            .bind(to: self.model)
            .disposed(by: disposeBag)
        
    }
}

fileprivate struct Dummy {
    static let data: [Contact] = [
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
}
