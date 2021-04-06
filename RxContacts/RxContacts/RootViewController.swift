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
    private var sections: [ContactSection] = []
    
    // MARK: Views
    private lazy var rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(touchedAddContact)
        )
    }()
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
        
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
    }
    
    private func bind() {
        sections = [
            ContactSection(header: "a", items: [1,2]),
            ContactSection(header: "b", items: [1,2,3]),
        ]
        subject.accept(sections)
        
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
        
        subject
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    // MARK: Methods
    @objc private func touchedAddContact(sender: Any) {
        sections.append(ContactSection(header: "ㅎ", items: [1,2,3,4,5]))
        subject.accept(sections)
    }
    
}
