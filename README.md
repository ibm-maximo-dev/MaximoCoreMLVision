# Visual Recognition with Core ML and integrate with Maximo

Classify images with [Watson Visual Recognition](https://www.ibm.com/watson/services/visual-recognition/) and [Core ML](https://developer.apple.com/machine-learning/). Update Maximo Asset Management with the classified results. The images are classified offline using a deep neural network that is trained by Visual Recognition. The results are conveyed to Maximo using iOS OSLC SDK.

- **MaximoCoreMLVision **: Train a custom Visual Recognition model for more specialized classification.

## Pre-requisites

- Make sure that you have installed [Xcode 9][xcode_download] or later and iOS 11.0 or later. These versions are required to support Core ML.
- Maximo 7.6.0.9 or higher is necessary for integration using Maximo iOS OSLC SDK

## Getting the files
Use GitHub to clone the repository locally, or download the .zip file of the repository and extract the files.

## Running MaximoCoreMLVision
This project builds and trains a Visual Recognition model (also called a classifier) to identify different anamolies found while inspecting London Bridge (Bridge open, Bridge close, Man in water..). Use the [Watson Swift SDK](https://github.com/watson-developer-cloud/swift-sdk) to download, manage, and execute the trained model. By using the Watson Swift SDK, you don't have to learn about the underlying Core ML framework. This project uses Maximo iOS OSLC SDK client to communicate with Maximo, including logging in and creating work orders.

### Setting up Visual Recognition in Watson Studio
1.  Log into [Watson Studio][watson_studio_visrec_tooling]. From this link you can create an IBM Cloud account, sign up for Watson Studio, or log in.
1.  After you sign up or log in, you'll be on the Visual Recognition instance overview page in Watson Studio.

    **Tip**: If you lose your way in any of the following steps, click the `IBM Watson` logo on the top left of the page to bring you to the the Watson Studio home page. From there you can access your Visual Recognition instance by clicking the **Launch tool** button next to the service under "Watson services".

### Training the model
1.  In Watson Studio on the Visual Recognition instance overview page, click **Create Model** in the Custom box.
1.  If a project is not yet associated with the Visual Recognition instance you created, a project is created. Name your project `Custom Core ML` and click **Create**.

    **Tip**: If no storage is defined, click **refresh**.
1.  Upload each .zip file of sample images from the `Training Images` directory onto the data pane on the right side of the page.  Add the `hdmi_male.zip` file to your model by clicking the **Browse** button in the data pane. Also add the `usb_male.zip`, `thunderbolt_male.zip`, and `vga_male.zip` files to your model.
1.  After the files are uploaded, select **Add to model** from the menu next to each file, and then click **Train Model**.

### Copy your Model ID and API Key
1.  In Watson Studio on the custom model overview page, click your Visual Recognition instance name (it's next to Associated Service).
1.  Scroll down to find the **Custom Core ML** classifier you just created.
1.  Copy the **Model ID** of the classifier.
1.  In the Visual Recognition instance overview page in Watson Studio, click the **Credentials** tab, and then click **View credentials**. Copy the `api_key` or the `apikey` of the service.

    **Important**: Instantiation with `api_key` works only with Visual Recognition service instances created before May 23, 2018. Visual Recognition instances created after May 22 use IAM.

### Adding the classifierId and apiKey to the project
1.  Open the project in XCode.
1.  Copy the **Model ID** and paste it into the **classifierID** property in the [ImageClassificationViewController](../master/Core%20ML%20Vision%20Custom/Core%20ML%20Vision%20Custom/ImageClassificationViewController.swift) file.
1.  Copy either your **api_key** or **apikey** and paste it into either the **api_key** or **apikey** property in the  [ImageClassificationViewController](../master/Core%20ML%20Vision%20Custom/Core%20ML%20Vision%20Custom/ImageClassificationViewController.swift) file.

### Downloading the Watson Swift SDK
Use the Carthage dependency manager to download and build the Watson Swift SDK.

1.  Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage).
1.  Open a terminal window and navigate to the `Core ML Vision Custom` directory.
1.  Run the following command to download and build the Watson Swift SDK:

    ```bash
    carthage bootstrap --platform iOS
    ```

**Tip:** Regularly download updates of the SDK so you stay in sync with any updates to this project.

### Installing Maximo iOS OSLC SDK
Use pod to instance Maximo iOS OSLC SDK
#### Cocoapods installation

Open a terminal session and enter the following command:
```
sudo gem install cocoapods
```

#### Add SSH key to your GitHub account

Generate the RSA key for your GitHub user account:
```
ssh-keygen -t rsa -b 4096 -C git@github.ibm.com
```
Paste the contents of the <i>id_rsa.pub</i> file as described here: https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

#### Project setup

1. In a terminal session, navigate to the directory that contains your Xcode project.

> **Note**: If your project is already configured to use Cocoapods, you can skip the next step.

2. Enter the following command:
```
pod init
```

3. Type the following command to open the Podfile by using Xcode for editing:
```
open -a Xcode Podfile
```

The following code shows the default Podfile:

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '<YOUR PROJECT NAME>' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for <YOUR PROJECT NAME>

end
```

Delete the # and space before "platform" and delete the other lines that start with "#".
Your Podfile now looks like the following example:

```
platform :ios, '9.0'

target '<YOUR PROJECT NAME>' do
  use_frameworks!

end
```
4. Add the following line to your Podfile, right after "use_frameworks!":
```
pod 'MaximoRESTSDK', '1.0.0'
```

5. Install the dependencies for your project by entering the following command in the terminal session:
```
pod install
```

After the dependencies are successfully installed, Cocoapods creates a new <YOUR PROJECT NAME>.xcworkspace file and a Pods folder that contains all the project's dependencies.
Now, open the .xcworkspace file by using Xcode, and you are all ready to go.

### Testing the custom model

1. Open `MaximoCoreMLVision.xcworkspace` in Xcode.
1. Select MaximoCoreMLVision project and select MaximoCoreMLVision schema. Modify the bundle identifier to be unique within your organization. Select appropriate development 'team' and 'Signing Certificate'
1. Run the application in the simulator or on a device.
1. Classify an image by clicking the camera icon and selecting a photo from your photo library. To add a custom image in the simulator, drag the image from the Finder to the simulator window.
1. Pull new versions of the visual recognition model with the refresh button in the bottom right.

    **Tip:** The classifier status must be `Ready` to use it. Check the classifier status in Watson Studio on the Visual Recognition instance overview page.
1. By default both Maximo and Watson configurations are set to dummy values. Before running classifications edit both configurations and add correct values.
## What to do next

Create different classifiers for different use cases using [Watson Studio][watson_studio_visrec_tooling], configure this project with the new classifiers and test classifications.

## Resources

- [Watson Visual Recognition](https://www.ibm.com/watson/services/visual-recognition/)
- [Watson Visual Recognition Tool][vizreq_tooling]
- [Apple machine learning](https://developer.apple.com/machine-learning/)
- [Core ML documentation](https://developer.apple.com/documentation/coreml)
- [Watson Swift SDK](https://github.com/watson-developer-cloud/swift-sdk)
- [IBM Cloud](https://bluemix.net)

[xcode_download]: https://developer.apple.com/xcode/downloads/
[vizreq_tooling]: https://dataplatform.ibm.com/registration/stepone?context=wdp&apps=watson_studio&target=watson_vision_combined
[watson_studio_visrec_tooling]: https://dataplatform.ibm.com/registration/stepone?target=watson_vision_combined&context=wdp&apps=watson_studio&cm_sp=WatsonPlatform-WatsonPlatform-_-OnPageNavCTA-IBMWatson_VisualRecognition-_-CoreMLGithub
