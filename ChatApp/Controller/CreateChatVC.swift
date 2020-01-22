//
//  CreateChatVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/3/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit
import Firebase

class CreateChatVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Variables
    private var currentChannelAlertController: UIAlertController?
    private var viewModel: CreateChatViewModel!
    private var chatTitle: String?
    
    // MARK: - Public Variables
    public var chatCreated: ((_ chat: Chats, _ chatTitle: String?) -> ())?
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Loading.shared.showProgressView(view)

        viewModel = CreateChatViewModel(delegate: self)
        
        viewModel.fetchAllUsers()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIdentifier(for: segue) == .MembersVC, let destinationVC = segue.destination as? MembersVC {
            destinationVC.viewModel = self.viewModel
            destinationVC.chatTitle = chatTitle
            destinationVC.createdChat = {[unowned self] (chat) in
                Loading.shared.showProgressView(self.view)
                self.viewModel.createChat(chat)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func createGPTapped(_ sender: UIButton) {
        createAlertView(chatType: .group, title: "Group Title", buttonTitle: "Next", placeHolder: "Group title")
    }
    
    @IBAction func privateChatTapped(_ sender: UIButton) {
        createAlertView(chatType: .one2one, title: "Search User", buttonTitle: "Search", placeHolder: "Username/name")
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Helpers
    
    @objc private func textFieldDidChange(_ field: UITextField) {
      guard let ac = currentChannelAlertController else {
        return
      }
      
      ac.preferredAction?.isEnabled = field.hasText
    }
    
    // MARK: - Helpers
    private func createAlertView(chatType: ChatType, title: String, buttonTitle: String, placeHolder: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { [unowned self] field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.clearButtonMode = .whileEditing
            field.placeholder = placeHolder
            field.returnKeyType = .done
        }
        
        let createAction = UIAlertAction(title: buttonTitle, style: .default, handler: { [unowned self] _ in
            
            if chatType == .group {
                self.getUsers()
            } else {
                self.searchUser(name: nil)
            }
            
        })
        createAction.isEnabled = false
        ac.addAction(createAction)
        ac.preferredAction = createAction
        
        present(ac, animated: true) {
            ac.textFields?.first?.becomeFirstResponder()
        }
        currentChannelAlertController = ac
    }
    
    private func getUsers() {
        
        guard viewModel.totalUserCount != 0 else { return }
        
        let title = currentChannelAlertController?.textFields?.first?.text ?? ""
        chatTitle = title
        self.performSegue(withIdentifier: .MembersVC, sender: nil)
    }
    
    private func searchUser(name: String?) {
        Loading.shared.showProgressView(view)
        var userName = ""
            
        if name != nil {
            userName = name ?? ""
        } else {
            userName = currentChannelAlertController?.textFields?.first?.text ?? ""
        }

        chatTitle = userName
        viewModel.fetchUser(with: userName)
    }
}

extension CreateChatVC: CreateChatViewModelDelegate {
    func onUserFetchCompleted() {
        Loading.shared.hideProgressView()
        tableView.reloadData()
    }
    
    func onUserFetchFailed(with reason: String) {
        Loading.shared.hideProgressView()
        print("Couldn't Create Chat with reason: ", reason)
    }
    
    func onChatCreated(with chat: Chats) {
        Loading.shared.hideProgressView()
        chatCreated?(chat, chatTitle)
        self.dismiss(animated: true, completion: nil)
        print("Chat Created Successfully")
    }
    
    func onChatFailed(with reason: String) {
        Loading.shared.hideProgressView()
        print("Couldn't Create Chat with reason: ", reason)
    }
}

// MARK: - Segue
extension CreateChatVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case MembersVC
    }
}

// MARK: - TableView DataSource
extension CreateChatVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalUserCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath)
        cell.textLabel?.text = viewModel.user(at: indexPath.row).name
        cell.detailTextLabel?.text = "@\(viewModel.user(at: indexPath.row).username ?? "")"
        
        return cell
    }
}

// MARK: - TableView Delegate
extension CreateChatVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userName = viewModel.user(at: indexPath.row).name
        
        searchUser(name: userName)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = #colorLiteral(red: 0.1254901961, green: 0.1882352941, blue: 0.2549019608, alpha: 1)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
        header.contentView.backgroundColor =  #colorLiteral(red: 0.5176470588, green: 0.5803921569, blue: 0.6470588235, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a user to start chatting with them"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
