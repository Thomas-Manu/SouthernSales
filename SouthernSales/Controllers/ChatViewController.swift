//
//  ChatViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 4/7/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import FirebaseFirestore

class ChatViewController: MessagesViewController {
    
    var channel: Channel?
    var listing: Listing?
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        title = channel?.title ?? ""
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.backgroundColor = Colors.BackgroundColor
        
        messageInputBar.delegate = self
        messageInputBar.tintColor = Colors.TintColor
        
        getAllMessages()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        messageListener?.remove()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatViewController {
    private func getAllMessages() {
        guard let channel = channel else {
            return
        }
        Utility.databaseReadAllMessagesFromChannel(channel: channel, listener: { (listener) in
            self.messageListener = listener
        }, success: { (messages) in
            self.messages = messages
            self.messages.sort { (lhs, rhs) -> Bool in
                return lhs.sentDate < rhs.sentDate
            }
            self.messagesCollectionView.reloadData()
        }, change: { (change) in
            self.handleNewMessages(change)
        }) { (error) in
            print("[CVC] Error: \(error)")
        }
    }
    
    private func handleNewMessages(_ change: DocumentChange) {
        switch change.type {
        case .added:
            insertNewMessage(message: Utility.parseMessage(from: change.document.data(), withID: change.document.reference.documentID))
        default:
            break
        }
    }
    
    private func insertNewMessage(message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        messages.sort { (lhs, rhs) -> Bool in
            return lhs.sentDate < rhs.sentDate
        }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = ""
        
        if let channel = channel {
            Utility.databaseSendMessage(message: text, throughChannel: channel) { (error) in
                print("[CVC] Error: \(error)")
            }
        } else {
            guard let reference = listing?.reference else {
                return
            }
            Utility.databaseReadListing(fromReference: reference, success: { (listing) in
                guard let listing = listing else {
                    return
                }
                Utility.databaseCreateChannel(fromListing: listing, success: { (channel) in
                    guard let channel = channel else {
                        return
                    }
                    Utility.databaseSendMessage(message: text, throughChannel: channel, failure: { (error) in
                        print("[CVC] Error: \(error)")
                    })
                }) { (error) in
                    print("[CVC] Error: \(error)")
                }
            }) { (error) in
                print("[CVC] Error: \(error)")
            }
        }
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> Sender {
        return Sender(id: "WcWtEpANFMbaHpR0hnIkWFLwN793", displayName: "Thomas M")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
