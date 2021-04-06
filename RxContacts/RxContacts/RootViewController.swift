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
    private let subject = BehaviorRelay<[ContactSection]>(value: [])
    private var sections: [ContactSection] = [
        ContactSection(header: "a", items: [1,2]),
        ContactSection(header: "b", items: [1,2,3]),
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
        
        let dataSource = RxTableViewSectionedReloadDataSource<ContactSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath)
            cell.textLabel?.text = String(repeating: "*", count: item)
            return cell
        }
        dataSource.titleForHeaderInSection = { (dataSource, index) in
            return dataSource.sectionModels[index].header
        }
        dataSource.sectionIndexTitles = { dataSource in
            return dataSource.sectionModels.map { $0.header }
        }
        
        subject.accept(sections)
        subject
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: Methods
    private func touchedAddContact() {
        sections.append(ContactSection(header: "ㅎ", items: [1,2,3,4,5]))
        subject.accept(sections)
    }
    
}
