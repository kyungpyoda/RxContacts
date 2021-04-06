//
//  RootViewController.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/05.
//

import UIKit
import SnapKit

class RootViewController: UIViewController {
    
    // MARK: Properties
    
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
        
    }
    
    // MARK: Methods
    @objc private func touchedAddContact(sender: Any) {
        print("TODO: ADD")
    }
    
}
