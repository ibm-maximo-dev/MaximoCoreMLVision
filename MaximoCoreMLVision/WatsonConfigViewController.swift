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
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let watsonDict = dict["WatsonConfig"] {
                if let value = watsonDict["WatsonVRAPIKey"] {
                    defaults.set(value, forKey: "WatsonVRAPIKey")
                }
                if let value = watsonDict["WatsonVRClassifiers"] {
                    defaults.set(value, forKey: "WatsonVRClassifiers")
                }
                if let value = watsonDict["WatsonVRAPIVersion"] {
                    defaults.set(value, forKey: "WatsonVRAPIVersion")
                }
                if let value = watsonDict["WatsonVRClasses"] {
                    defaults.set(value, forKey: "WatsonVRClasses")
                }
                if let value = watsonDict["WatsonVRConfidenceScore"] {
                    defaults.set(value, forKey: "WatsonVRConfidenceScore")
                }
                print(watsonDict)
            }
        }
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
        let watsonKey = defaults.string(forKey: "WatsonVRAPIKey") ?? ""
        let watsonVersion = defaults.string(forKey: "WatsonVRAPIVersion") ?? ""
        let vrClassifiers = defaults.string(forKey: "WatsonVRClassifiers") ?? ""
        

        apiKey.text = watsonKey
        classifierIDs.text = vrClassifiers
        apiVersion.text = watsonVersion

    }
}
