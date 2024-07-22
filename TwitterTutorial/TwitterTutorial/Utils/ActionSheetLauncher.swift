//
//  ActionSheetLauncher.swift
//  TwitterTutorial
//
//  Created by Daehoon Lee on 7/6/24.
//

import SnapKit
import Then
import UIKit

private let reuseIdentifier = "ActionSheetCell"

protocol ActionSheetLauncherDelegate: AnyObject {
    func didSelect(option: ActionSheetOptions)
}

class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties
    
    private let user: User
    private let tableView = UITableView()
    private lazy var viewModel = ActionSheetViewModel(user: user)
    private lazy var actionSheetHeight = CGFloat(viewModel.options.count * 60) + 100
    
    weak var delegate: ActionSheetLauncherDelegate?
    
    private lazy var blackView = UIView().then { view in
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        view.addGestureRecognizer(tapGesture)
    }
    
    private lazy var footerView = UIView().then { view in
        view.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        cancelButton.layer.cornerRadius = 50 / 2
    }
    
    private lazy var cancelButton = UIButton(type: .system).then { button in
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGroupedBackground
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
        configureTableView()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += self.actionSheetHeight
        } completion: { _ in
            self.blackView.removeFromSuperview()
            self.tableView.removeFromSuperview()
        }
    }
    
    // MARK: - Helpers
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        window.addSubview(blackView)
        blackView.frame = window.frame
        
        window.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: actionSheetHeight)
                
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.tableView.frame.origin.y -= self.actionSheetHeight
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ActionSheetCell else { return UITableViewCell() }
        
        cell.option = viewModel.options[indexPath.row]
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.tableView.frame.origin.y += self.actionSheetHeight
        } completion: { _ in
            self.delegate?.didSelect(option: option)
        }
    }
}
