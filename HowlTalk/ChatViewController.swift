//
//  ChatViewController.swift
//  HowlTalk
//
//  Created by 최고은 on 2019/11/24.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton : UIButton!
    
    var chatRoomUid : String?
    var comments : [ChatModel.Comment] = []
    
    // 테이블뷰 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // 테이블뷰 셀 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myUid = Auth.auth().currentUser!.uid
        
        //내가 보낸 메세지인지 비교하는 부분
        if(comments[indexPath.row].uid! == myUid){
            //내가 보낸 메세지
            //print(indexPath.row)
            var myCell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            
            //메세지 입력
            myCell.messageLabel.text = comments[indexPath.row].message
            return myCell
        } else {
            //상대방 메세지
            var destinationCell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath) as! DestinationMessageCell
            //메세지 입력
            destinationCell.messageLabel.text = comments[indexPath.row].message
            return destinationCell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: UIControl.Event.touchUpInside)
        getMessageList()
    }
    
    @objc func sendMessage() {
        var myUid = Auth.auth().currentUser?.uid
        var message : [String : Any] = [
            "uid" : myUid!,
            "message" : textField.text!,
            "timestamp" : ServerValue.timestamp()
        ]
        
        Database.database().reference()
        .child("chatrooms")
        .child(chatRoomUid!)
        .child("comments")
        .childByAutoId()
        .setValue(message, withCompletionBlock: { (err, ref) in
            self.textField.text = ""
        })
    }
    
    // 메세지 받아오기
    func getMessageList() {
        Database.database().reference()
        .child("chatrooms")
        .child(chatRoomUid!)
        .child("comments")
            .observe(DataEventType.value) { (DataSnapshot) in
                //print(DataSnapshot.childrenCount) // 코멘트 갯수
                self.comments.removeAll()
                for child in DataSnapshot.children {
                    var item = child as! DataSnapshot
                    var value = item.value as! [String:Any]
                    var commentsFromServer = ChatModel.Comment(JSON: value)
                    self.comments.append(commentsFromServer!)
                }
                self.mainTableView.reloadData()
        }
    }
    
//    func getDestinationUserInfo(){
//        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
//            let dic = datasnapshot.value as! [String:Any]
//            self.userModel = UserModel(JSON: dic)
//            self.getMessageList()
//                   
//        })
//        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
//        // Do any additional setup after loading the view.
//    }
}

class MyMessageCell : UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
}

class DestinationMessageCell : UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}
