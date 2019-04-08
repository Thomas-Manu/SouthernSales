//
//  ChatViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 4/7/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseFirestore

class ChatViewController: MessagesViewController {
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

//extension ChatViewController: MessagesDataSource {
//    func currentSender() -> Sender {
//        
//    }
//    
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        
//    }
//    
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        
//    }
//    
//    
//}
