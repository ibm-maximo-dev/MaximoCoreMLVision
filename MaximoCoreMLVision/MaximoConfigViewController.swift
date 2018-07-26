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
        loadFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            defaults.set(url.text, forKey: "MaximoURL")
            defaults.set(adminID.text, forKey: "MaximoAdminID")
            defaults.set(password.text, forKey: "MaximoAdminPassword")
        }
    }
    func loadFields() {
        let maxURL = defaults.string(forKey: "MaximoURL") ?? "http://127.0.0.1:9080/maximo"
        let maximoAdminStr = defaults.string(forKey: "MaximoAdminID") ?? "wilson"
        let maximoPwd = defaults.string(forKey: "MaximoAdminPassword") ?? "wilson"
/*
         let watsonKey = defaults.string(forKey: "WatsonVRAPIKey") ?? "bd7c6815fafd62f286e6c7970dc72bfb4f3e1c04"
         let watsonVersion = defaults.string(forKey: "WatsonVRAPIVersion") ?? "2018-05-31"
         let vrClassifiers = defaults.string(forKey: "WatsonVRClassifiers") ?? "TravisIOTWFv2_467145223,LondonBridge_394835703"
        apiKey.text = watsonKey
        classifierId.text = vrClassifiers
*/
        url.text = maxURL
        adminID.text = maximoAdminStr
        password.text = maximoPwd
    }
}
