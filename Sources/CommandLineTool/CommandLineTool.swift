//
//  File.swift
//  
//
//  Created by Phil Wilson on 18/1/20.
//

import Foundation
import vuhnNetwork
import ConsoleOutputTool
import ConfigurationTool


public final class CommandLineTool {
    private var consoleOutputTool: ConsoleOutputTool?
    private var configurationTool: ConfigurationTool
    
    private var connectedNodes = [String: NetworkUpdate]()

    private let arguments: [String]

    public init(configurationTool: ConfigurationTool, arguments: [String] = CommandLine.arguments) {
        self.consoleOutputTool = configurationTool.configurationModel.consoleOutputTool
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

        if let listeningPortString = configurationTool.configurationModel.configurationDictionary[.listeningPort],
            let listenPortInt = Int(listeningPortString) {
            makeOutBoundConnections(to: configurationTool.configurationModel.addressesArray, listenPort: listenPortInt) { (dictionary, error) in
                if let error = error {
                    print("updateHandler: error \(error)")
                }

                if dictionary["information"] != nil {
                    
                    for key in dictionary.keys.sorted() {
                        guard let nodeUpdate = dictionary[key] else { break }
                        
                        if let node = nodeUpdate.node,
                            nodeUpdate.type == .socketClosed {
                            let (anAddress, aPort) = NetworkAddress.extractAddress(node.address, andPort: node.port)
                            self.connectedNodes["\(anAddress):\(aPort)"] = nil
                            print("\(anAddress):\(aPort)      \(nodeUpdate.type.displayText())")
//                            self.consoleOutputTool?.clearDisplay()
//                            self.consoleOutputTool?.displayInformation(networkUpdate: nodeUpdate, error: nil, status: .information)
                            self.redrawConnectedNodes()
                        } else if nodeUpdate.type == .shutDown {
                            print("      \(nodeUpdate.type.displayText())")
//                            self.consoleOutputTool?.clearDisplay()
//                            self.consoleOutputTool?.displayInformation(networkUpdate: nodeUpdate, error: nil, status: .information)
                        }
                    }
                } else {
                    // Use sorted dictionary keys
                    for key in dictionary.keys.sorted() {
                        guard let nodeUpdate = dictionary[key],
                            let node = nodeUpdate.node else { break }
                        let (anAddress, aPort) = NetworkAddress.extractAddress(node.address, andPort: node.port)
                        self.connectedNodes["\(anAddress):\(aPort)"] = nodeUpdate
                    }
                    self.redrawConnectedNodes()
                }
            
            }
        }
    }
    
    private func redrawConnectedNodes() {
        for (_, key) in self.connectedNodes.keys.sorted().enumerated() {
            guard let nodeUpdate = self.connectedNodes[key] else { break }
            if let node = nodeUpdate.node {
                let (anAddress, aPort) = NetworkAddress.extractAddress(node.address, andPort: node.port)
                let sentMessage = node.sentNetworkUpdateType.displayText()
                let receivedMessage = node.receivedNetworkUpdateType.displayText()
                let connectionType = node.connectionType.displayText()

                print("\(anAddress):\(aPort)     \(connectionType)   \(sentMessage)   \(receivedMessage) \(nodeUpdate.type.displayText())")
                
//                self.consoleOutputTool?.displayNode(nodeIndex: UInt8(index), connectionType: connectionType, address: "\(anAddress):\(aPort)", sentMessage: sentMessage, receivedMessage: receivedMessage, status: .success)
            }
        }
    }
    
    private func printConfigurationData() {
        print("printConfigurationData\n")
        
        print("configurationModel.configurationDictionary:")
        for configurationData in configurationTool.configurationModel.configurationDictionary {
            print("                \(configurationData.key) \(configurationData.value)")
        }
        print("")
        
        print("configurationModel.addressesArray:")
        if configurationTool.configurationModel.addressesArray.isEmpty {
            print("                Empty")
        } else {
            for address in configurationTool.configurationModel.addressesArray {
                print("                \(address)")
            }
        }
        print("")
    }
}
