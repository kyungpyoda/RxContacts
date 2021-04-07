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

final class ContactsViewController: UIViewController {
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
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
    var viewModel: ContactsViewModel
    
    // MARK: Views
    private let addContactButton = UIButton(type: .contactAdd)
    private let tableView = UITableView().then {
        $0.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier)
    }
    private let searchController = UISearchController()

    // MARK: Initialize
    
    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NO WAY")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        bind(viewModel: self.viewModel)
        setUpUI()
    }
    
    func bind(viewModel: ContactsViewModel) {
        self.viewModel.sectionedContacts
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        self.addContactButton.rx.tap
            .bind(to: viewModel.tap)
            .disposed(by: disposeBag)
        
        self.searchController.searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(200), latest: true, scheduler: MainScheduler.instance)
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
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
    
}
