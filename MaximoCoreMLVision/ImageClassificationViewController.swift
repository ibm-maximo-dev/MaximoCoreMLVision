/**
 * Copyright IBM Corporation 2017, 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import CoreML
import Vision
import ImageIO
import VisualRecognitionV3
import MaximoRESTSDK

class ImageClassificationViewController: UIViewController {
    // MARK: - IBOutlets
    private let defaults = UserDefaults.standard
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var currentModelLabel: UILabel!
    @IBOutlet weak var updateModelButton: UIBarButtonItem!
    @IBOutlet weak var maxConnLabel: UILabel!
    //    var apiKey = "25a8eIbk99b2xb05WUzrLP9Qqe_CAk2-_Iz6o91luMHG"
    //    let classifierId = "DefaultCustomModel_1423968048"
    var apiKey = "bd7c6815fafd62f286e6c7970dc72bfb4f3e1c04"
    let classifierId = "NYMTA3_1771885209"
    let version = "2018-06-07"
    var maximoUrl = "http://localhost:9080/maximo"
    var maximoAdminID = ""
    var maximoPassword = ""
    var visualRecognition: VisualRecognition!
    var useLocalModels: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let apiKey = defaults.string(forKey: "WatsonVRAPIKey") {
            self.apiKey = apiKey
        }
        self.visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
        
        if let maximoUrl = defaults.string(forKey: "MaximoURL") {
            self.maximoUrl = maximoUrl
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Pull down model if none on device
        let localModels = try? visualRecognition.listLocalModels()
        print(localModels as Any)
        
        if let models = localModels, models.contains(self.classifierId)  {
            self.currentModelLabel.text = "Current Model: \(self.classifierId)"
        } else {
            self.invokeModelUpdate()
        }
        
        getClassifierDetails(apiKey: self.apiKey, classifierID: self.classifierId)
    }
    
    //MARK: - Model Methods
    
    func invokeModelUpdate()
    {
        let failure = { (error: Error) in
            print(error)
            let descriptError = error as NSError
            DispatchQueue.main.async {
                self.currentModelLabel.text = descriptError.code == 401 ? "Error updating model: Invalid Credentials" : "Error updating model"
                SwiftSpinner.hide()
            }
            self.useLocalModels = false
        }
        
        let success = {
            DispatchQueue.main.async {
                self.currentModelLabel.text = "Current Model: \(self.classifierId)"
                SwiftSpinner.hide()
            }
            self.useLocalModels = true
        }
        
        SwiftSpinner.show("Compiling model...")
        
        visualRecognition.updateLocalModel(classifierID: classifierId, failure: failure, success: success)
    }
    
    
    @IBAction func updateModel(_ sender: Any) {
        self.invokeModelUpdate()
    }
    
    
    // MARK: - Photo Actions
    
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    // MARK: - Image Classification
    
    func classifyImage(for image: UIImage, localThreshold: Double = 0.0) {
        
        classificationLabel.text = "Classifying..."
        var maxMsg: String = ""
        
        let failure = { (error: Error) in
            self.showAlert("Could not classify image", alertMessage: error.localizedDescription)
        }
        let recognized = { (classifiedImages: ClassifiedImages) in
            //print(classifiedImages)
            var topClassification = "None Recognized"
            var topScore = 0.0
            if classifiedImages.images.count > 0 && classifiedImages.images[0].classifiers.count > 0 && classifiedImages.images[0].classifiers[0].classes.count > 0 {
                let classesCount = classifiedImages.images[0].classifiers[0].classes.count
                for i in 0 ..< classesCount {
                    let score = Double(classifiedImages.images[0].classifiers[0].classes[i].score!)
                    if score > topScore {
                        topScore = score
                        topClassification = classifiedImages.images[0].classifiers[0].classes[i].className
                    }
                }
            } else {
                topClassification = "Unrecognized"
            }
            let classificationMsg = "Top Score: \(String(format: "%.2f", topScore)), and Top Class: \(topClassification)"
            let woNum = String(format: "%6d", arc4random())
            print(woNum)
            if(topScore > localThreshold) {
                let workorder = MaximoAPI.shared().buildWorkOrder(woText: woNum, description: classificationMsg, duration: 30)
                do {
                    let createMsg = try MaximoAPI.shared().createWorkOrder(workOrder: workorder)
                    print(createMsg)
                    maxMsg = "Connected"
                }
                catch OslcError.serverError(let code, let message){
                    maxMsg = "Error creating work order: \(message) with code \(code)"
                }
                catch OslcError.invalidConnectorInstance {
                    maxMsg = "Error creating work order: Not Connected to Maximo"
                }
                catch {
                    maxMsg = "Error creating work order: Undefined"
                }
            }
            // Update UI on main thread
            DispatchQueue.main.async {
                // Display top classification ranked by confidence in the UI.
                self.classificationLabel.text = classificationMsg
                print(maxMsg)
                self.maxConnLabel.text = maxMsg
            }
            
            
        }
        if(self.useLocalModels) {
            visualRecognition.classifyWithLocalModel(image: image, classifierIDs: [classifierId], threshold: localThreshold, failure: failure) { classifiedImages in
                recognized(classifiedImages)
            }
        }
        else {
            visualRecognition?.classify(image: image, threshold: localThreshold, classifierIDs: [classifierId], failure: failure) { classifiedImages in
                recognized(classifiedImages)
            }
        }
        
    }
    
    func getClassifierDetails(apiKey: String, classifierID: String) {
        let failure = { (error: Error) in
            self.showAlert("Could not classify image", alertMessage: error.localizedDescription)
        }
        let success = { (vrclass: Classifier) in
            print(vrclass)
        }
        visualRecognition.getClassifier(classifierID: classifierID, headers: nil, failure: failure, success: success)
    }
    
    
    //MARK: - Error Handling
    
    // Function to show an alert with an alertTitle String and alertMessage String
    func showAlert(_ alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension ImageClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image
        
        classifyImage(for: image, localThreshold: 0.2)
    }
}


