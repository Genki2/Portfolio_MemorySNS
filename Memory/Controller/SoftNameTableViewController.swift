//
//  TableViewController.swift
//  Memory
//
//  Created by GENKI Mac on 2021/11/07.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SoftNameTableViewController: UITableViewController {
    
    //DBの場所を指定
    let fireStoreDB = Firestore.firestore().collection("soft").document("soFnPZWp7aI3WU3cl5bc")
    
    var softNameArray = [String]()
    var selectedSoftName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.tableView.allowsSelection = true
        
        //ログイン状態の確認
        if UserDefaults.standard.object(forKey: "userName") == nil {
            print("未ログイン")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController")
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
          }
        else {
            print("ログイン済み")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //===============================
        // MARK: fireStoreデータ取得処理
        //===============================
        //getDocument _ データベースからドキュメントを取得
        fireStoreDB.getDocument { [self] (document, error) in
            
            if error != nil{
                return
            }
            
            //ドキュメントの中身を取得
            let document = document?.data()
            let documentName = document!["softType"] as! String
            
            // softTypeの中身{ swift Kotorin }
            softNameArray = documentName.components(separatedBy: " ")
            
            //リロードする
            self.tableView.reloadData()
        }
    }
    
    //===============================
    // MARK: tableView処理
    //===============================

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return softNameArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        label1.text = softNameArray[indexPath.row]
        return cell
    }
    
    //Cellをタップした時の動作
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //タップした場所の値を渡す
        selectedSoftName = softNameArray[indexPath.row]
        
        //画面遷移
        let ListTableVC = self.storyboard?.instantiateViewController(identifier: "ListTableVC") as! TitleTableViewController
        ListTableVC.collectionName = selectedSoftName
        self.navigationController?.pushViewController(ListTableVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 70
    }
}
