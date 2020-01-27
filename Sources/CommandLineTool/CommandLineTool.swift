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


public final class CommandLineTool
{
    private var consoleOutputTool: ConsoleOutputTool?
    private var configurationTool: ConfigurationTool

    private let arguments: [String]

    public init(configurationTool: ConfigurationTool, arguments: [String] = CommandLine.arguments)
    {
        self.consoleOutputTool = configurationTool.configurationModel.consoleOutputTool
        self.configurationTool = configurationTool
        self.arguments = arguments
    }

    public func run() throws
    {
        if CommandLine.arguments.contains("-help") {
            configurationTool.configurationModel.printUsage()
            return
        }
        /*
        // Test display of simple node data
        consoleOutputTool?.displayNode(nodeIndex: 0, address: "0-127.0.0.1:8333", sentMessage: "Ping", receivedMessage: "Awaiting Pong", status: 2)
        
        consoleOutputTool?.displayNode(nodeIndex: 1, address: "1-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutputTool?.displayNode(nodeIndex: 2, address: "2-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Version", receivedMessage: "Awaiting VerAck", status: 1)
        
        consoleOutputTool?.displayNode(nodeIndex: 3, address: "3-127.0.0.1:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutputTool?.displayNode(nodeIndex: 4, address: "4-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 2)*/

//        print("    Commandline parameters found:")
        if CommandLine.arguments.contains("-connectTo") {
//            print("        -connectTo")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-connectTo" {
                    let data = arguments[index+1]
                    configurationTool.configurationModel.configurationDictionary[.connectTo] = data
                    let addresses = data.split(separator: ",")
//                    print("            addresses: ")
                    for address in addresses {
                        print("                \(address)", terminator: "")
                        // Only add this address if it doesn't already exist
                        var needsAppending = true
                        for (index, currentAddress) in configurationTool.configurationModel.addressesArray.enumerated() {
                            let (aCurrentAddress, _) = NetworkAddress.extractAddress(String(currentAddress))
                            let (anAddress, _) = NetworkAddress.extractAddress(String(address))
                            if aCurrentAddress == anAddress {
//                                print(" ( inside configuration file )", terminator: "")
                                // Overwrite configuration file address with commandline
                                // The address may be the same, the port number may be changed
                                configurationTool.configurationModel.addressesArray[index] = String(address)
                                needsAppending = false; break }
                        }
//                        print("")
                        if needsAppending == true {
                            configurationTool.configurationModel.addressesArray.append(String(address))
                        }
                    }
//                    print("")
                }
            }
        }
        if CommandLine.arguments.contains("-dataDirectory") {
//            print("        -dataDirectory")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-dataDirectory" {
                    let path = arguments[index+1]
//                    print("            path: ")
//                    print("                \(path)")
//                    print("")
                    configurationTool.configurationModel.configurationDictionary[.dataDirectory] = path
                }
            }
        }
        configurationTool.configurationModel.configurationDictionary[.listeningPort] = "8333"
        if CommandLine.arguments.contains("-\(ConfigurationModel.OptionType.listeningPort.rawValue)") {
//            print("        -listeningPort")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-\(ConfigurationModel.OptionType.listeningPort.rawValue)" {
                    let listeningPort = arguments[index+1]
//                    print("            Port: \(listeningPort)")
//                    print("")
                    configurationTool.configurationModel.configurationDictionary[.listeningPort] = listeningPort
                }
            }
        }
//        printConfigurationData()

        if let listeningPortString = configurationTool.configurationModel.configurationDictionary[.listeningPort],
            let listenPortInt = Int(listeningPortString) {
            makeOutBoundConnections(to: configurationTool.configurationModel.addressesArray, listenPort: listenPortInt) { (dictionary, error) in
                if let error = error {
                    print("updateHandler: error \(error)")
                }
//                else {
//                    print("updateHandler:  dictionary \(dictionary)")
//                }
                

                if let information = dictionary["information"] {
                    
                } else {
                    // sort dictionary values ?
                    for nodeUpdate in dictionary {
//                        print("                \(nodeUpdate.key) \(nodeUpdate.value)")

                        // Outbound Nodes
//                        for (index, currentAddress) in self.configurationTool.configurationModel.addressesArray.enumerated() {
//                            let (aCurrentAddress, _) = NetworkAddress.extractAddress(currentAddress)

                            // ([String: NetworkUpdate],Error?)
                            let networkUpdate = nodeUpdate.value
//                            print("aCurrentAddress \(index) \(aCurrentAddress) anAddress \(anAddress)")
//                            if aCurrentAddress == anAddress {
                                if let node = networkUpdate.node {
                                    let (anAddress, aPort) = NetworkAddress.extractAddress(node.address, andPort: node.port)
                                    let sentMessage = node.sentNetworkUpdateType.displayText()
                                    let receivedMessage = node.receivedNetworkUpdateType.displayText()
                                    print("sentMessage = \(sentMessage)      receivedMessage = \(receivedMessage)")
                                    self.consoleOutputTool?.displayNode(nodeIndex: 0, address: "\(anAddress):\(aPort)", sentMessage: sentMessage, receivedMessage: receivedMessage, status: .success)
                                }
//                                break
//                            }
//                        }
                        
                        
                    }
                }
            
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
