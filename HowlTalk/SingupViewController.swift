//
//  SingupViewController.swift
//  HowlTalk
//
//  Created by 최고은 on 2019/11/10.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import ObjectMapper

class SingupViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    @IBOutlet weak var eamilIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var mainImageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.addTarget(self, action: #selector(actionSignup), for: UIControl.Event.touchUpInside)
        // Do any additional setup after loading the view.
//        Database.database().reference()
//        .child("users")
//        .child("6639ZqjZG6WfgulfhIJQtf9Pr0w2")
//        .observe(DataEventType.value) { (snopshot) in       // 푸시드리블방식
//            print(snopshot.value)
//        }
        
        albumButton.addTarget(self, action: #selector(actionSelectImage), for: UIControl.Event.touchUpInside)
        signupButton.addTarget(self, action: #selector(actionSignup), for: UIControl.Event.touchUpInside)
    }

    @objc func actionSelectImage() {
        var pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //화면 종료 코드 (앨범 선택 창 닫는 기능)
        dismiss(animated: true, completion: nil)
        
        var image = info[.originalImage] as? UIImage
        mainImageview.image = image
    }
    
    @objc func actionSignup() {
        // 1단계 : 아이디 생성
        Auth.auth().createUser(withEmail: eamilIdTextField.text!, password: passwordTextField.text!) { (auth, err) in
            if(err == nil) {
                print("join!!")
                var uid = auth?.user.uid    // 유저의 대한 고유번호
                
                //사진 용량이 크기때문에 10분 1로 줄여주자.
                let data = self.mainImageview.image?.jpegData(compressionQuality: 0.1)
                // 이미지를 저장할 경로
                let riversRef =  Storage.storage().reference()
                    .child("images")
                    .child("\(uid!).png")
                // 2단계 : 이미지 업로드 코드
                riversRef.putData(data!, metadata: nil) { (metadata, error) in
                  // 이미지 업로드 후 이미지 URL 주소 받는 코드
                    riversRef.downloadURL { (url, error) in
                        //print(url)
                        var urlClass = URL(string: url!.absoluteString)
                        self.mainImageview.sd_setImage(with: urlClass, completed: nil)
                        
                        var userModel = UserModel()
                        userModel.userName = self.nameTextField.text
                        userModel.uid = uid
                        userModel.profileImageUrl = url?.absoluteString
                        userModel.userEmail = self.eamilIdTextField.text
                        userModel.userPassword = self.passwordTextField.text
                        
                        // 3단계 : 데이터베이스에 개인정보 입력
                        Database.database().reference()
                            .child("users")                 // database의 테이블 같은 것, 맵 방식처럼 작동
                            //.childByAutoId()
                            .child(uid!)
                            .setValue(userModel.toJSON())
                    }
                }
            } else {
                print("err : \(String(describing: err))")
            }
            //print(auth?.user)
        }
    }
    
    func strTrimFunc(str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
