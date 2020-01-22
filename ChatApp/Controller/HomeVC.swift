//
//  HomeVC.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Variables
    private var chatTitle: String?
    private var viewModel: ChatsViewModel!
    private var chat: Chats!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // init viewModel
        viewModel = ChatsViewModel(delegate: self)
        
        // Show a loading and fetch data
        Loading.shared.showProgressView(view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = img
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        self.viewModel.fetchChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // set back navigation bar border
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
        
        if viewModel != nil {
            viewModel.removeListener()
        }
    }
    
    deinit {
        if viewModel != nil {
            viewModel.removeListener()
        }
    }
    
    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIdentifier(for: segue) == .ChatVC, let destinationVC = segue.destination as? ChatVC {
            destinationVC.chatTitle = self.chatTitle
            destinationVC.user = viewModel.currentUser
            destinationVC.chat = self.chat
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let chatType = viewModel.chatType(at: indexPath.row)
                destinationVC.chatType = chatType
            }
            
        } else if segueIdentifier(for: segue) == .CreateChatVC, let destinationVC = segue.destination as? CreateChatVC {
            destinationVC.chatCreated = {[unowned self] (chat, title) in
                self.chatTitle = title
                self.chat = chat
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addBtnTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: .CreateChatVC, sender: nil)
    }
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            return ChatCell()
        }
        
        let chat = viewModel.chat(at: indexPath.row)
        let chatTitle = viewModel.chatTitle(at: indexPath.row)
        cell.configureCell(chat: chat, title: chatTitle)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - TableView Delegate
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chat = viewModel.chat(at: indexPath.row)
        self.chatTitle = viewModel.chatTitle(at: indexPath.row)
        performSegue(withIdentifier: .ChatVC, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Segue
extension HomeVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case ChatVC
        case CreateChatVC
    }
}

extension HomeVC: ChatsViewModelDelegate {
    func onFetchCompleted(with index: Int) {
        Loading.shared.hideProgressView()
        tableView.reloadData()
    }
    
    func onUpdateCompleted(with index: Int) {
        tableView.reloadData()
    }
    
    func onRemoveCompleted(with index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        Loading.shared.hideProgressView()
        print("Couldn't Fetch Chats with reason: ", reason)
    }
}
