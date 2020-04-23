//
//  ChatVC.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import Photos

class ChatVC: MessagesViewController {
    
    // MARK: - Outlets
    
    // MARK: - Private Variables
    private var viewModel: MessagesViewModel!
    private var errorType: ErrorTypes!
    private var chatId: String?
    private let outgoingAvatarOverlap: CGFloat = 17.5
    
    private var isSendingPhoto = false {
      didSet {
        DispatchQueue.main.async {
            if self.isSendingPhoto {
                Loading.shared.showProgressView(self.view)
            } else {
                Loading.shared.hideProgressView()
            }
        }
      }
    }
    
    // MARK: - Public Variables
    public var chatTitle: String?
    public var user: User!
    public var chat: Chats!
    public var chatType: ChatType!
    public var userImage: UIImage?
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
       addImageToNavBar(with: userImage)
        
        title = chatTitle
        
        maintainPositionOnKeyboardFrameChanged = true
        let inputStyle = FacebookInputBar()
        messageInputBar = inputStyle
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1568627451, blue: 0.2588235294, alpha: 1)
        setupMessageLayout()
        
        inputStyle.buttonTapped = {[unowned self] (tapped) in
            self.cameraButtonPressed()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initMessageViewModel()
        
        
    }
    
    deinit {
        viewModel.removeListener()
    }
    
    // MARK: - Actions
    @objc func barButtonItemTapped() {
        
    }
    
    // MARK: - Helpers
    private func initMessageViewModel() {
        
        self.chatId = chat.id
        
        // init viewModel
        viewModel = MessagesViewModel(delegate: self, chatId: chatId)
        
        // Show a loading and fetch data
        Loading.shared.showProgressView(view)
        self.viewModel.fetchMessages()
    }
    
    private func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        parent?.createActionSheet(title: "Set Profile Picture", message: "Choose From:", LibAction: { [unowned self] (_) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
            }, cameraAction: { [unowned self] (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.sourceType = .camera
                    self.present(picker, animated: true, completion: nil)
                }
        })
    }
    
    private func setupMessageLayout() {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        
        // Set outgoing avatar to overlap with the message bubble
        
        if chatType == .some(.group) {
            layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
            layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
            layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
        } else {
            layout?.setMessageIncomingAvatarSize(.zero)
        }
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func addImageToNavBar(with image: UIImage?) {
        
        let button = UIButton.init(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(barButtonItemTapped), for: .touchUpInside)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .black
    }
   
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.white]
            }
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {

        switch message.kind {
        case .emoji:
            return .clear
        default:
           return isFromCurrentSender(message: message) ? .primary : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        let gradientLayer = CAGradientLayer()

        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !viewModel.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !viewModel.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            gradientLayer.removeFromSuperlayer()
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !viewModel.isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !viewModel.isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        

        return .custom { [unowned self] view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
//            if self.isFromCurrentSender(message: message) {
//                gradientLayer.colors = [#colorLiteral(red: 0.2666666667, green: 0.1960784314, blue: 0.6784313725, alpha: 1).cgColor, #colorLiteral(red: 0.3098039216, green: 0.6980392157, blue: 0.9921568627, alpha: 1).cgColor]
//                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//
//                gradientLayer.locations = [0.15, 1.0]
//                gradientLayer.frame = view.bounds
//
//                view.layer.insertSublayer(gradientLayer, below: view.layer.sublayers?.last)
//            } else {
//                gradientLayer.colors = [#colorLiteral(red: 0.1294117647, green: 0.1568627451, blue: 0.2588235294, alpha: 1).cgColor, #colorLiteral(red: 0.07843137255, green: 0.1098039216, blue: 0.2196078431, alpha: 1).cgColor]
//                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//
//                gradientLayer.locations = [0.15, 1.0]
//                gradientLayer.frame = view.bounds
//
//                view.layer.insertSublayer(gradientLayer, below: view.layer.sublayers?.last)
//            }
            
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if chatType == .some(.one2one) {
            avatarView.isHidden = true
            avatarView.frame = .zero
        } else {
            avatarView.isHidden = viewModel.isNextMessageSameSender(at: indexPath)
            avatarView.layer.borderWidth = 2
            avatarView.layer.borderColor = UIColor.primary.cgColor
        }
    }
}


// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
        func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            if chatType == .some(.group) {
                if isFromCurrentSender(message: message) {
                    return !viewModel.isPreviousMessageSameSender(at: indexPath) ? 20 : 0
                } else {
                    return !viewModel.isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
                }
            } else {
                return 0
            }
        }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!viewModel.isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}


// MARK: - MessageInputBarDelegate

extension ChatVC: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard let id = chatId else {
            print("id not found")
            return
        }
        
        let message = Message(user: user, content: text, chatId: id)
        viewModel.saveMessages(message)
        inputBar.inputTextView.text = ""
    }
}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: user.uid, displayName: DataService.shared.name ?? "")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.totalCount
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.message(at: indexPath.section)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !viewModel.isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !viewModel.isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        return nil
    }
}

// MARK: - MessagesViewModel Delegate
extension ChatVC: MessagesViewModelDelegate {
    func onUploadImageCompleted(with url: URL, image: UIImage) {
        self.isSendingPhoto = false
        guard let id = chatId else { return }
        var message = Message(user: self.user, image: image, chatId: id)
        message.downloadURL = url
        
        self.viewModel.saveMessages(message)
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func onFetchCompleted(_ isLatestMessage: Bool) {
        
        if messagesCollectionView.backgroundView != nil {
            messagesCollectionView.backgroundView = nil
        }
        
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
        Loading.shared.hideProgressView()
    }
    
    func onFetchFailed(with reason: String, errorType: ErrorTypes?) {
        // Show alert to user
        Loading.shared.hideProgressView()
        
        if errorType == .chatIsNotCreated {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: messagesCollectionView.frame.width, height: 80))
            label.text = reason
            label.textColor = .darkGray
            label.textAlignment = .center
            messagesCollectionView.backgroundView = label
            self.errorType = errorType
        }
        
        print(reason)
    }
    
    func onSaveCompleted() {
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func onSaveFailed(with reason: String) {
        print(reason)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // 1
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: nil) { [unowned self] result, info in
                    
                    guard let image = result else {
                        return
                    }
                    
                    self.isSendingPhoto = true
                    self.viewModel.sendPhoto(image)
            }
            
            // 2
        } else if let image = info[.originalImage] as? UIImage {
            self.isSendingPhoto = true
            self.viewModel.sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
