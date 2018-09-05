//
//  MaximoConfigViewController.swift
//  MaximoCoreMLVision
//
//  Created by Hari Narasimhamurthy on 7/24/18.
//

import Foundation
import UIKit

class MaximoConfigViewController: UITableViewController {
    private let defaults = UserDefaults.standard

    @IBOutlet weak var url: UITextField!
    
    @IBOutlet weak var adminID: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let maxDict = dict["MaximoConfig"] {
                if let value = maxDict["MaximoURL"] {
                    defaults.set(value, forKey: "MaximoURL")
                }
                if let value = maxDict["MaximoAdminID"] {
                    defaults.set(value, forKey: "MaximoAdminID")
                }
                if let value = maxDict["MaximoAdminPassword"] {
                    defaults.set(value, forKey: "MaximoAdminPassword")
                }
                print(maxDict)
            }
        }
        loadFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("URL: \(url.text ?? "") ")
        print("adminID: \(adminID.text ?? "") ")
        if isMovingFromParentViewController {
            defaults.set(url.text, forKey: "MaximoURL")
            defaults.set(adminID.text, forKey: "MaximoAdminID")
            defaults.set(password.text, forKey: "MaximoAdminPassword")
        }
    }
    func loadFields() {
        let maxURL = defaults.string(forKey: "MaximoURL") ?? "http://127.0.0.1:9080/maximo"
        let maximoAdminStr = defaults.string(forKey: "MaximoAdminID") ?? ""
        let maximoPwd = defaults.string(forKey: "MaximoAdminPassword") ?? ""

        url.text = maxURL
        adminID.text = maximoAdminStr
        password.text = maximoPwd
    }
}
