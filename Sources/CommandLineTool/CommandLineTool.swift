//
//  File.swift
//  
//
//  Created by Phil Wilson on 18/1/20.
//

import Foundation
import vuhnNetwork
import ConfigurationTool

public final class CommandLineTool {
    private var configurationTool: ConfigurationTool
    
    private var connectedNodes = [String: NetworkUpdate]()

    private let arguments: [String]
    
    private var nodeManager = NodeManager()
    
    public func close() {
        nodeManager.close()
    }

    public init(configurationTool: ConfigurationTool, arguments: [String] = CommandLine.arguments) {
        self.configurationTool = configurationTool
        self.arguments = arguments
    }

    public func run() throws {
        
        if CommandLine.arguments.contains("-help") {
            configurationTool.configurationModel.printUsage()
            return
        }

        if CommandLine.arguments.contains("-connectTo") {
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-connectTo" {
                    let data = arguments[index+1]
                    configurationTool.configurationModel.configurationDictionary[.connectTo] = data
                    let addresses = data.split(separator: ",")
                    for address in addresses {
                        // Only add this address if it doesn't already exist
                        var needsAppending = true
                        let (anAddress, aPort) = NetworkAddress.extractAddress(String(address))
                        let addressKey = "\(anAddress):\(aPort)"
                        for (index, currentAddress) in configurationTool.configurationModel.addressesArray.enumerated() {
                            let (aCurrentAddress, aCurrentPort) = NetworkAddress.extractAddress(String(currentAddress))
                            let currentAddressKey = "\(aCurrentAddress):\(aCurrentPort)"
                            if currentAddressKey == addressKey {
                                // Overwrite configuration file address with commandline
                                // The address may be the same, the port number may be changed
                                configurationTool.configurationModel.addressesArray[index] = addressKey
                                needsAppending = false; break }
                        }
                        if needsAppending == true {
                            configurationTool.configurationModel.addressesArray.append(addressKey)
                        }
                    }
                }
            }
        }
        if CommandLine.arguments.contains("-dataDirectory") {
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-dataDirectory" {
                    let path = arguments[index+1]
                    configurationTool.configurationModel.configurationDictionary[.dataDirectory] = path
                }
            }
        }
        configurationTool.configurationModel.configurationDictionary[.listeningPort] = "8333"
        if CommandLine.arguments.contains("-\(ConfigurationModel.OptionType.listeningPort.rawValue)") {
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-\(ConfigurationModel.OptionType.listeningPort.rawValue)" {
                    let listeningPort = arguments[index+1]
                    configurationTool.configurationModel.configurationDictionary[.listeningPort] = listeningPort
                }
            }
        }
        print("\n\nconfigurationTool.configurationModel.addressesArray\n\(configurationTool.configurationModel.addressesArray)\n\n")
        var listeningPort: Int? = nil
        if let listeningPortString = configurationTool.configurationModel.configurationDictionary[.listeningPort] {
            listeningPort = Int(listeningPortString)
        }
        nodeManager.configure(with: configurationTool.configurationModel.addressesArray, and: listeningPort ?? -1)
        
        nodeManager.startListening()
        nodeManager.connectToOutboundNodes()
        
        dispatchMain()
    }
}
