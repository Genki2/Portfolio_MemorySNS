//
//  TimeLineTableViewController.swift
//  Memory
//
//  Created by GENKI Mac on 2021/11/08.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class PostedTableViewController: UITableViewController {
    
    var selectedName = String()
    var collectionName = String()
    var fireStoreDBArray:[FireStoreDBModel] = []
    var selectedTitleArray:[FireStoreDBModel] = []
    
    // PostTimeLineTableViewController内でPostボタンを押した場合 2　とする
    var postFlag = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //削除
        selectedTitleArray.removeAll()
        
        //同じタイトルの投稿があった場合1つにまとめる処理
        for i in fireStoreDBArray{
            if i.title == selectedName {
                selectedTitleArray.append(i)
            }
        }
        //リロードする
        self.tableView.reloadData()
    }
    
    //===============================
    // MARK: ボタンアクション処理
    //===============================
    @IBAction func tappedPostBtn(_ sender: Any) {
        //画面遷移
        let PostVC = self.storyboard?.instantiateViewController(identifier: "PostVC") as! PostViewController
        PostVC.selectedTitle = selectedName
        PostVC.collectionName = collectionName
        PostVC.postFlag = postFlag
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
        return selectedTitleArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(3) as! UILabel
        let contentsImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label1 = cell.contentView.viewWithTag(2) as! UILabel
        
        label.text = "投稿者:" + selectedTitleArray[indexPath.row].username
        contentsImageView.sd_setImage(with:  URL(string:selectedTitleArray[indexPath.row].contentImage),
                                      placeholderImage: UIImage(named: "noImage"), options: .continueInBackground, completed: nil)
        label1.text = selectedTitleArray[indexPath.row].comment

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 700
    }
}
