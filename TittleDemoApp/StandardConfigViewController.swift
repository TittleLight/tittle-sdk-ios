//
//  StandardConfigViewController.swift
//  TittleDemoApp
//
//  Created by Jackie on 4/9/2018.
//  Copyright © 2018 clarityhk.com. All rights reserved.
//

import UIKit

class StandardConfigViewController: UIViewController {

    @IBOutlet weak var wifiNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FunctionsTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    /*
    // MARK: - Button actions
    */
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        print("123")
    }
    
    

}
