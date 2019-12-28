//
//  ViewController.swift
//  HowlTalk
//
//  Created by 최고은 on 03/11/2019.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mainTableView: UITableView!
    
    var strArray = ["철수", "민수", "철민"]
    var imageArray = [UIImage(named: "p1"), UIImage(named: "p2"), UIImage(named: "p3")]
    var array : [UserModel] = []          //친구 목록
    //var destinationUid : String?        //상대방 UID
    var chatRoomUid : String?
    var myUid : String?
    var destiantnionUid : String?
    
    // 셀을 몇개 보여줄지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    // 셀 갯수만큼 function 호출
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        myUid = Auth.auth().currentUser?.uid
        
        var myItemCell = cell as! MyItemCell
        //if(myUid != array[indexPath.row].uid!) {
            // 이름 맵핑
            myItemCell.nameLable.text =  array[indexPath.row].userName
            // 이미지 맵핑
            let url = array[indexPath.row].profileImageUrl
            myItemCell.mainImageView.sd_setImage(with: URL(string : url!), completed: nil)
        //}
        
        return myItemCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // indexPath가 몇 번째를 선택했는지 알려줌
        myUid = Auth.auth().currentUser?.uid
        destiantnionUid = array[indexPath.row].uid
        Database.database().reference()
            .child("chatrooms")
            .queryOrdered(byChild: "users/" + myUid!)
            .queryEqual(toValue: true)
            .observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
                        
                //방이 하나도 없을때
                if(datasnapshot.childrenCount == 0){
                    self.createRoom(uid: self.myUid!, destinationUid: self.destiantnionUid!)
                    return
                }

                //내가 소속된 방을 다 읽어옴
                for child in datasnapshot.children{
                    var item = child as! DataSnapshot
                    var value = item.value as! [String : Any]
                    var chatModel = ChatModel(JSON: value)

                    //일일이 방을 탐색하면서 내가 대화하고 싶은 상대방이 있는 방의 이름 값을 가져옴
                    if(chatModel?.users[self.destiantnionUid!] == true){
                        //방이 존재할때
                        self.chatRoomUid = item.key
                        self.performSegue(withIdentifier: "detailChatSeuge", sender: nil)
                        break
                    } else {
                        //방이 존재하지 않을때 생성
                        self.createRoom(uid: self.myUid!,destinationUid: self.destiantnionUid!)
                    }
                }
            })
    }
    
    // 방 생성 코드
    func createRoom(uid : String, destinationUid : String){
        let createRoomInfo : Dictionary<String, Any> = [
            "users" : [
                uid: true,
                destinationUid: true
            ]
        ]
        
        // 데이터베이스 chartromms에 createRoomInfo 맵을 지정
        Database.database().reference()
            .child("chatrooms")
            .childByAutoId()
            .setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                //print(err)
                // 방번호를 가져오는 부분
                self.chatRoomUid = ref.key
                self.performSegue(withIdentifier: "detailChatSeuge", sender: nil)
        })
    }
    
    // 화면전환 할 때 데이터 전송
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailChatSeuge") {
            var vc = segue.destination as! ChatViewController
            vc.chatRoomUid = self.chatRoomUid  //vc.chatRoomUid: 채팅 화면, self.chatRoomUid: 친구 목록 화면
            //vc.myUid = self.myUid
            //vc.destiantnionUid = self.destiantnionUid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        loadPeopleList()
    }
    
    func loadPeopleList() {
        myUid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            self.array.removeAll()
            // 데이터 파싱 및 Array에 담기
            print("--------loadPeopleList-----------")
            for child in snapshot.children {
                let item = child as! DataSnapshot
                let value = item.value as! [String : Any]
                let userModel = UserModel(JSON: value)
                if(userModel?.uid == self.myUid){
                    continue
                }
                self.array.append(userModel!)
                
            }
            self.mainTableView.reloadData()
        }
    }
}

class MyItemCell : UITableViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
}
