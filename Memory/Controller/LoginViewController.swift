//
//  LoginViewController.swift
//  Memory
//
//  Created by GENKI Mac on 2021/11/07.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var textfild: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //ログイン処理
    func login(){
        
        //Firestore ログイン
        Auth.auth().signInAnonymously { (authResult, error) in
            
            guard let user = authResult?.user else { return }
            
            let uid = user.uid
            print(uid)
            UserDefaults.standard.set(self.textfild.text, forKey: "userName")
        }
    }

    @IBAction func done(_ sender: Any) {
        login()
        //初回ログイン時のみ表示なので閉じる
        self.dismiss(animated: true, completion: nil)
    }
}
