//
//  PostViewController.swift
//  Memory
//
//  Created by GENKI Mac on 2021/11/08.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class PostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate{
    
    var collectionName = String()
    var downLoadImageURL:URL?
    var username = String()
    var selectedTitle = ""
    var postFlag = 0
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var titleText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username = UserDefaults.standard.object(forKey: "userName") as! String
        commentTextView.text = ""
        commentTextView.delegate = self
        titleText.delegate = self
        postBtn.isEnabled = false
        
        //同じタイトルで投稿の場合、タイトルの入力不要
        if selectedTitle != ""{
            titleText.text = selectedTitle
            titleText.isEnabled = false
        }
    }
    
    //===============================
    // MARK: ボタンアクション処理
    //===============================
    @IBAction func tappedPostImage(_ sender: Any) {
                    print("tap")
                    openActionSheet()
    }
    
    //投稿処理
    @IBAction func tappedPostBtn(_ sender: Any) {
        
        if commentTextView.text == "" || downLoadImageURL!.absoluteString == "" || titleText.text == "" {
            
            let alert = UIAlertController(title: "注意", message: "未記入箇所がございます", preferredStyle: .alert)
            //ここから追加
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            //ここまで追加
            present(alert, animated: true, completion: nil)
        }
        else {
            
            print("collectionName ==> \(collectionName)")
            
            //Firestoreのコレクションとドキュメント作成
            Firestore.firestore().collection(collectionName).document().setData(
                [
                    "title": titleText.text as Any,
                    "comment": commentTextView.text as Any,
                    "contentImage":downLoadImageURL!.absoluteString,
                    "username":username
                ]
            )
        }
        
        // PostTimeLineTableViewController内でPostボタンを押した場合2とする
        if postFlag == 2 {
            self.navigationController?.popToViewController(navigationController!.viewControllers[2], animated: true)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //===============================
    // MARK: imagePicker デリゲート
    //===============================
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage{
            
            self.contentImageView.image = pickedImage
            sendAndGetImageURL()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //===============================
    // MARK: キーボード処理
    //===============================
    //キーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.resignFirstResponder()
    }
    
    //リターンキーでテキストフィールドを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //===============================
    // MARK: アクションシート処理
    //===============================
    
    func openActionSheet(){
        let alert = UIAlertController(title: "選択してください。", message: "", preferredStyle: .actionSheet)
        let cameraAction:UIAlertAction = UIAlertAction(title: "カメラから", style: .default) { (alert) in
        
               let sourceType = UIImagePickerController.SourceType.camera
               if UIImagePickerController.isSourceTypeAvailable(.camera){
                   
                   let cameraPicker = UIImagePickerController()
                   cameraPicker.sourceType = sourceType
                   cameraPicker.delegate = self
                   cameraPicker.allowsEditing = true
                   
                   //カメラを出す
                   self.present(cameraPicker,animated: true)
                   
               }else{
                   print("エラーです。")
               }
        }
        
        let albumAction = UIAlertAction(title: "アルバムから", style: .default) { (alert) in
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                let albumPicker = UIImagePickerController()
                albumPicker.sourceType = sourceType
                albumPicker.delegate = self
                albumPicker.allowsEditing = true
                
                //カメラを出す
                self.present(albumPicker,animated: true)
                
            }else{
                print("エラーです。")
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            print("キャンセル")
        }
        
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    //===============================
    // MARK: FireStoregeへ送信処理
    //===============================
    func sendAndGetImageURL(){
        
        // FireStoregeにcontentImageのフォルダ作成
        // アップロードする画像名ユニーク
        let imageRef = Storage.storage().reference().child("contentImage").child("\(UUID().uuidString).jpg")
        var imageData:Data = Data()
        
        //アップロード画像データ圧縮処理
        if self.contentImageView.image != nil{
            imageData = (self.contentImageView.image?.jpegData(compressionQuality: 0.5))!
        }
        
        //HUD表示
        HUD.dimsBackground = false
        HUD.show(.progress)
        print(imageData)
        
        //FireStoregeにアップロード
        let uploadTask = imageRef.putData(imageData, metadata:nil) { (metaData, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            imageRef.downloadURL { (downloadURL, error) in
                    
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                
                //HUD非表示
                HUD.hide()
                
                //FireStoregeにアップロードした際のdownloadURLを代入
                self.downLoadImageURL = downloadURL
                self.postBtn.isEnabled = true
            }
        }
        uploadTask.resume()
    }
    
}
