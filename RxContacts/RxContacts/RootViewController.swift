//
//  RootViewController.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/05.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class RootViewController: UIViewController {
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private var filteredItems = BehaviorSubject<[Contact]>(value: [])
    private var items: [Contact] = [
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
    
    // MARK: Views
    private let addContactButton = UIButton(type: .contactAdd)
    private lazy var tableView = UITableView()
    private lazy var searchController = UISearchController()

    // MARK: Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        setUpUI()
        bind()
    }
    
    private func setUpUI() {
        title = "Contacts"
        view.backgroundColor = .systemBackground
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addContactButton)
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
    }
    
    private func bind() {
        self.addContactButton.rx.tap
            .bind { [weak self] in
                self?.touchedAddContact()
            }
            .disposed(by: disposeBag)
        
        self.searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind { [weak self] searchQuery in
                self?.filteredItems.onNext(self?.searchItems(with: searchQuery) ?? []) // 검색어로 필터링
            }
            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<ContactSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath)
            cell.textLabel?.text = "\(item.fullName)"
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource, index) in
            return dataSource.sectionModels[index].header
        }
        dataSource.sectionIndexTitles = { dataSource in
            return dataSource.sectionModels.map { $0.header }
        }
        
        self.filteredItems
            .flatMapLatest { [unowned self] (items) -> Observable<[ContactSection]> in
                self.splitToSections(with: items) // 필터링 된 Contact 객체들을 headerLetter를 기준으로 Section으로 분리
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: Methods
    private func touchedAddContact() {
        items.append(Contact(fullName: "피자"))
        filteredItems.onNext(items)
    }
    
    private func searchItems(with query: String = "") -> [Contact] {
        return items.filter {
            return $0.fullName.hasPrefix(query)
        }
    }
    
    private func splitToSections(with items: [Contact]) -> Observable<[ContactSection]> {
        var dict: [String: [Contact]] = [:]
        items.forEach {
            dict[$0.fullName.headerLetter] = (dict[$0.fullName.headerLetter] ?? []) + [$0]
        }
        return Observable.just(
            dict.sorted(by: ({ $0.key < $1.key })).map { section in
                ContactSection(header: section.key, items: section.value.sorted(by: { $0.fullName < $1.fullName }))
            }
        )
    }
    
}
