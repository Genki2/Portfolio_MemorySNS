//
//  ListTableViewController.swift
//  Memory
//
//  Created by GENKI Mac on 2021/11/08.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class TitleTableViewController: UITableViewController ,UISearchBarDelegate{
    
    var collectionName = String()
    var fireStoreDBArray:[FireStoreDBModel] = []
    var titeArray:[String] = []
    var selectedTitle = String()
    
    //検索結果
    var searchResult:[String] = []
    
    //検索初期値
    var serchRecet:[String] = []
    
    //DBの場所を指定
    let fireStoreDB = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "投稿タイトル"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Listdataをリセットする　＊戻るたびに増えている
        fireStoreDBArray.removeAll()
        
        //===============================
        // MARK: fireStoreデータ取得処理
        //===============================
        fireStoreDB.collection("\(collectionName)").getDocuments { [self] (document, error) in
            
            if error != nil{
                return
            }
            
            //ドキュメントの中身全て取得
            if let documentArray = document?.documents{
                
                //ドキュメントの中身1つ1つ確認
                for doc in documentArray{
                    
                    //ドキュメントの中身のデータ取得
                    let data = doc.data()
                    
                    //FireStoreDBModel作成
                    let FireStoreDBModel = FireStoreDBModel (title: (data["title"] as? String)!,
                                             comment: (data["comment"] as? String)!,
                                             contentImage:(data["contentImage"] as? String)!,
                                             username: (data["username"] as? String)!)
                    //fireStoreDBArray作成
                    self.fireStoreDBArray.append(FireStoreDBModel)
                    
                    //タイトル名取得
                    for i in self.fireStoreDBArray {
                        self.titeArray.append(i.title)
                    }
                    
                    //重複したタイトル名を削除
                    self.titeArray = self.titeArray.uniqued()
                    
                    //検索初期値代入
                    self.serchRecet = self.titeArray
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //===============================
    // MARK: ボタンアクション処理
    //===============================
    
    @IBAction func post(_ sender: Any) {
        
        //画面遷移
        let PostVC = self.storyboard?.instantiateViewController(identifier: "PostVC") as! PostViewController
        PostVC.collectionName = collectionName
        self.navigationController?.pushViewController(PostVC, animated: true)
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
        
        return titeArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        
        //label1.text = UniqueEArray[indexPath.row].title
        label1.text = titeArray[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 70
    }
    
    //Cellをタップした時の動作
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //タップした場所の値を渡す
        selectedTitle = titeArray[indexPath.row]
        
        //画面遷移
        let TimeLineTableVC = self.storyboard?.instantiateViewController(identifier: "TimeLineTableVC") as! PostedTableViewController
        TimeLineTableVC.selectedName = selectedTitle
        TimeLineTableVC.fireStoreDBArray = fireStoreDBArray
        TimeLineTableVC.collectionName = collectionName
        
        //Listdataをリセットする　＊戻るたびに増えている
        //Listdata.removeAll()
        self.navigationController?.pushViewController(TimeLineTableVC, animated: true)
    }
    
    //===========================
    // 検索機能↓
    // ==========================
    //searchBar設置
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let searchBar = UISearchBar()
        //プレースホルダーの文字設定
        searchBar.placeholder = "検索"
        
        //デリゲート先を自分に設定する
        searchBar.delegate = self
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.enablesReturnKeyAutomatically = false
        
        //隙間無くすコード
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        
        return searchBar
    }
    
    //searchBarの幅に合わせる為に必要な処理
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    // 検索バー編集開始時にキャンセルボタン有効化
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // キャンセルボタンでキャセルボタン非表示
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //検索結果配列を空にする。
        searchResult.removeAll()
        
        if(searchBar.text == "") {
            titeArray = serchRecet
            
        } else {
            //検索文字列を含むデータを検索結果配列に追加する。
            for title in serchRecet {
                if (title.contains(searchBar.text!)) {
                    searchResult.append(title)
                }
            }
            //titeArrayに入れる
            if searchResult != []{
                titeArray = searchResult
            }
        }
        //テーブルを再読み込みする。
        self.tableView.reloadData()
    }
}

extension Array {
  func uniqued() -> Array {
    return NSOrderedSet(array: self).array as! [Element]
  }
}
