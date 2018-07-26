//
//  MaximoConfig.swift
//  MaximoCoreMLVision
//
//  Created by Hari Narasimhamurthy on 7/23/18.
//


import Foundation
import MaximoRESTSDK

class MaximoConfig {
    
    var connected: Bool
    var connectionStatus: String
    var host: String
    var port: Int
    var maxID: String
    var maxPassword: String
    
    init(maxURL: String, maxID: String, maxPassword: String) {
        
        let url = URL(string: maxURL)
        let urlComp = URLComponents(url: url!, resolvingAgainstBaseURL: true)
        self.host = (urlComp?.host)!
        self.port = (urlComp?.port)!
        self.maxID = maxID
        self.maxPassword = maxPassword
        self.connected = false
        self.connectionStatus = ""
        self.login()
    }
    func login() {
        do {
            let loggedUser = try MaximoAPI.shared().login(userName: self.maxID, password: self.maxPassword,
                                                          host: self.host, port: self.port)
            print("Maximo Login Successful: ")
            connectionStatus = "Maximo: Login Successful to \(host):\(port)"
            connected = true
        }
        catch OslcError.loginFailure(let error) {
            print("Error: \(error)")
            connectionStatus = "Maximo: Error: \(error)"
            connected = false
        }
        catch OslcError.invalidRequest {
            print("Invalid Request supplied. Check hostname, port, username and password")
            connectionStatus = "Maximo: Invalid Request supplied. Check hostname, port, username and password"
            connected = false
        }
        catch {
            print("An error occurred during the Maximo login")
            connectionStatus = "Maximo:  An error occurred during the Maximo login"
            connected = false
        }
    }
}
