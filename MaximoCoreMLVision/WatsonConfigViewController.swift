//
//  WatsonConfigViewController.swift
//  MaximoCoreMLVision
//
//  Created by Hari Narasimhamurthy on 7/24/18.
//

import Foundation
import UIKit

class WatsonConfigViewController: UITableViewController {
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak var apiKey: UITextField!
    
    @IBOutlet weak var classifierIDs: UITextField!
    
    @IBOutlet weak var apiVersion: UITextField!
    
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
            defaults.set(apiKey.text, forKey: "WatsonVRAPIKey")
            defaults.set(classifierIDs.text, forKey: "WatsonVRClassifiers")
            defaults.set(apiVersion.text, forKey: "WatsonVRAPIVersion")
        }
    }

    func loadFields() {
        let watsonKey = defaults.string(forKey: "WatsonVRAPIKey") ?? "bd7c6815fafd62f286e6c7970dc72bfb4f3e1c04"
        let watsonVersion = defaults.string(forKey: "WatsonVRAPIVersion") ?? "2018-05-31"
        let vrClassifiers = defaults.string(forKey: "WatsonVRClassifiers") ?? "NYMTA3_1771885209"
        

        apiKey.text = watsonKey
        classifierIDs.text = vrClassifiers
        apiVersion.text = watsonVersion

    }
}
