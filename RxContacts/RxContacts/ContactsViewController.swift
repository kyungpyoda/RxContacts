//
//  ContactsViewController.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/05.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import Then
import ReactorKit

final class ContactsViewController: UIViewController, View {
    
    // MARK: Properties
    var disposeBag = DisposeBag()
    private let dataSource = RxTableViewSectionedReloadDataSource<ContactSection> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "\(item.fullName)"
        return cell
    }.then {
        $0.titleForHeaderInSection = { (dataSource, index) in
            return dataSource.sectionModels[index].header
        }
        $0.sectionIndexTitles = { dataSource in
            return dataSource.sectionModels.map { $0.header }
        }
    }
    
    // MARK: Views
    private let searchController = UISearchController()
    private let addContactButton = UIButton(type: .contactAdd)
    private let tableView = UITableView().then {
        $0.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier)
    }
    
    // MARK: Initialize
    init(reactor: ContactsViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("NO WAY")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        setUpUI()
    }
    
    private func setUpUI() {
        title = "Contacts"
        view.backgroundColor = .white
        view.backgroundColor = .systemBlue
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addContactButton)
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: Binding
    func bind(reactor: ContactsViewReactor) {
        self.addContactButton.rx.tap
            .map { Reactor.Action.add(Contact(fullName: "피자")) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.searchController.searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(200), latest: true, scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}
