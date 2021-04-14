//
//  AddContactViewController.swift
//  RxContacts
//
//  Created by 홍경표 on 2021/04/09.
//

import UIKit
import ReactorKit

class AddContactViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    private let leftBarButtonItem = UIButton(type: .system).then {
        $0.setTitle("Cancel", for: .normal)
    }
    private let rightBarButtonItem = UIButton(type: .system).then {
        $0.setTitle("Done", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: $0.titleLabel?.font.pointSize ?? UIFont.systemFontSize)
    }
    private let givenNameTextField = UITextField().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.05)
    }
    private let familyNameTextField = UITextField().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.05)
    }
    
    init(reactor: AddContactViewReactor) {
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
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftBarButtonItem)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightBarButtonItem).then {
            $0.isEnabled = false
        }
        
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .fill
            $0.layer.borderWidth = 1
            $0.spacing = 5
        }
        let givenNameStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .fill
            $0.spacing = 5
            let label = UILabel().then {
                $0.text = "이름"
                $0.textAlignment = .center
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
            $0.addArrangedSubview(label)
            $0.addArrangedSubview(givenNameTextField)
            label.snp.makeConstraints { $0.width.equalToSuperview().multipliedBy(0.3) }
        }
        let familyNameStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .fill
            $0.spacing = 5
            let label = UILabel().then {
                $0.text = "성"
                $0.textAlignment = .center
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
            $0.addArrangedSubview(label)
            $0.addArrangedSubview(familyNameTextField)
            label.snp.makeConstraints { $0.width.equalToSuperview().multipliedBy(0.3) }
        }
        stackView.addArrangedSubview(givenNameStackView)
        stackView.addArrangedSubview(familyNameStackView)
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(100)
        }
    }
    
    func bind(reactor: AddContactViewReactor) {
        self.leftBarButtonItem.rx.tap
            .map { _ in Reactor.Action.cancel }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rightBarButtonItem.rx.tap
            .map { _ in Reactor.Action.done }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.givenNameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .throttle(.milliseconds(200), latest: true, scheduler: MainScheduler.instance)
            .map { Reactor.Action.editGivenName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.familyNameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .throttle(.milliseconds(200), latest: true, scheduler: MainScheduler.instance)
            .map { Reactor.Action.editFamilyName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isDismissed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.givenName }
            .distinctUntilChanged()
            .bind(to: givenNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.familyName }
            .distinctUntilChanged()
            .bind(to: familyNameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.addable }
            .distinctUntilChanged()
            .bind(to: rightBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
