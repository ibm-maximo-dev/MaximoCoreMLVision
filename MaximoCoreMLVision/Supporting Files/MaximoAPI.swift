//
//  MaximoAPI.swift
//  MaximoCoreMLVision
//
//  Created by Hari Narasimhamurthy on 7/23/18.
//

import Foundation
import MaximoRESTSDK

public class MaximoAPI {
    private static var sharedMaximoAPI : MaximoAPI = {
        var maximoAPI = MaximoAPI()
        maximoAPI.initFromDefaults()
        return maximoAPI
    }()
    var connected: Bool?
    var connectionStatus: String?
    var host: String? = ""
    var port: Int? = 80
    var maxID: String? = ""
    var maxPassword: String? = ""
    
    var options: Options?
    var connector: MaximoConnector?
    var loggedUser: [String: Any] = [:]
    var workOrderSet: ResourceSet?
    var siteID : String = ""
    var orgID : String = ""
    private let defaults = UserDefaults.standard
    
    private init() {
        initFromDefaults()
    }
    
    func initFromDefaults() {
        if let maxURL = defaults.string(forKey: "MaximoURL") {
            let url = URL(string: maxURL)
            let urlComp = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            self.host = (urlComp?.host)!
            self.port = (urlComp?.port)!
            if let maxID = defaults.string(forKey: "MaximoAdminID") {
                self.maxID = maxID
            }
            if let maxPassword = defaults.string(forKey: "MaximoAdminPassword") {
                self.maxPassword = maxPassword
            }
            self.login()
        }
    }
    public class func shared() -> MaximoAPI {
        return sharedMaximoAPI
    }
    func login() {
        do {
            let loggedUser = try login(userName: self.maxID!, password: self.maxPassword!,
                                       host: self.host!, port: self.port!)
            print("Maximo Login Successful ")
            connectionStatus = "Maximo: Login Successful"
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
    public func login(userName: String, password: String, host: String, port: Int) throws -> [String: Any] {
        options = Options().user(user: userName).password(password: password).auth(authMode: "maxauth")
        options = options!.host(host: host).port(port: port).lean(lean: true)
        connector = MaximoConnector(options: options!)
        try connector!.connect()
        
        let personSet = connector!.resourceSet(osName: "mxperson")
        _ = try personSet._where(whereClause: "spi:personid=\"" + userName.uppercased() + "\"").fetch()
        let person = try personSet.member(index: 0)
        loggedUser = try person!.toJSON()
        
        if let lID = loggedUser["locationsite"] {
            siteID = lID as! String;
        }
        
        if let lID = loggedUser["locationsite"] {
            orgID = lID as! String
        }
        return loggedUser
    }
    
    public func listWorkOrders() throws -> [[String: Any]] {
        var workOrders : [[String: Any]] = []
        if let connector = self.connector {
            workOrderSet = connector.resourceSet(osName: "mxwo")
            _ = workOrderSet!.pageSize(pageSize: 10)
            _ = workOrderSet!._where(whereClause:
                "spi:istask=0 and spi:siteid=\"" + siteID + "\" and spi:orgid=\"" + orgID + "\"")
            _ = workOrderSet!.paging(type: true)
            _ = try workOrderSet!.fetch()
            
            let count = try workOrderSet!.count()
            if (count > 0) {
                for index in 0...count-1 {
                    let resource = try workOrderSet!.member(index: index)
                    workOrders.append(try resource!.toJSON())
                }
            }
        }
        return workOrders
    }
    
    public func nextWorkOrdersPage() throws -> [[String: Any]] {
        _ = try workOrderSet?.nextPage()
        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        for index in 0...count-1 {
            let resource = try workOrderSet!.member(index: index)
            workOrders.append(try resource!.toJSON())
        }
        
        return workOrders
    }
    
    public func previousWorkOrdersPage() throws -> [[String: Any]] {
        _ = try workOrderSet?.previousPage()
        let count = try workOrderSet!.count()
        var workOrders : [[String: Any]] = []
        for index in 0...count-1 {
            let resource = try workOrderSet!.member(index: index)
            workOrders.append(try resource!.toJSON())
        }
        
        return workOrders
    }
    
    public func updateWorkOrder(workOrder: [String: Any]) throws {
        if let conn = self.connector {
            let uri = conn.getCurrentURI() + "/os/mxwo/" + String(workOrder["workorderid"] as! Int)
            _ = try conn.update(uri: uri, jo: workOrder, properties: nil)
        }
        else {
            throw OslcError.invalidConnectorInstance
        }
    }
    
    public func deleteWorkOrder(workOrder: [String: Any]) throws {
        if let conn = self.connector {
            let uri = conn.getCurrentURI() + "/os/mxwo/" + String(workOrder["workorderid"] as! Int)
            _ = try conn.delete(uri: uri)
        }
        else {
            throw OslcError.invalidConnectorInstance
        }
    }
    
    public func createWorkOrder(workOrder: [String: Any]) throws -> [String: Any]  {
        var retVal : [String: Any] = [:]
        if let conn = self.connector {
            let uri = conn.getCurrentURI() + "/os/mxwo"
            retVal = try conn.create(uri: uri, jo: workOrder, properties: nil)
        }
        else {
            throw OslcError.invalidConnectorInstance
        }
        return retVal
    }
    
    public func listWorkOrderStatuses() throws -> [[String: Any]] {
        var resultList : [[String: Any]] = []
        if let conn = self.connector {
            let statusSet = conn.resourceSet(osName: "mxdomain")
            
            _ = statusSet._where(whereClause: "spi:domainid=\"WOSTATUS\"")
            _ = try statusSet.fetch()
            if let woStatusDomain = try statusSet.member(index: 0) {
                var woStatusJSON = try woStatusDomain.toJSON()
                var values : [Any] = woStatusJSON["synonymdomain"] as! [Any]
                var i = 0
                while (i < values.count) {
                    let domainValue : [String: Any] = values[i] as! [String : Any]
                    if (domainValue["defaults"] as! Int) == 1 {
                        resultList.append(domainValue)
                    }
                    i += 1
                }
            }
        }
        return resultList
    }
    
    func buildWorkOrder(woText: String, description: String, duration: Int) -> [String: Any] {
        var selectedWorkOrder : [String: Any]?
        selectedWorkOrder = [:]
        selectedWorkOrder!["wonum"] = woText
        selectedWorkOrder!["siteid"] = MaximoAPI.shared().loggedUser["locationsite"]
        selectedWorkOrder!["orgid"] = MaximoAPI.shared().loggedUser["locationorg"]
        
        selectedWorkOrder!["description"] = description
        selectedWorkOrder!["estdur"] = duration
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        var timeInterval = DateComponents()
        let scheduleStart = Date()
        timeInterval.minute = duration
        let scheduleFinish = Calendar.current.date(byAdding: timeInterval, to: scheduleStart)
        selectedWorkOrder!["schedstart"] = dateFormatter.string(from: scheduleStart)
        if scheduleFinish != nil {
            selectedWorkOrder!["schedfinish"] = dateFormatter.string(from: scheduleFinish!)
        }
        
        selectedWorkOrder!["status"] = "WAPPR"
        return selectedWorkOrder!
    }
    
    
}

