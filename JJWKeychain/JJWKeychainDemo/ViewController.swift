//
//  ViewController.swift
//  JJWKeychainDemo
//
//  Created by mrjia on 2019/10/11.
//  Copyright © 2019 norchant. All rights reserved.
//

import UIKit
import JJWKeychain
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let appIdentifier = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String
        let keychain = JJWKeychainKit(serviceName: "test.jjw.keychain", accessGroup: "com.jiajingwei.JJWKeychainDemo")
        if keychain.set("value", forKey: "key") {
            print("success")
        }else {
            print("false")
        }
        
        
        
        
    }


}

