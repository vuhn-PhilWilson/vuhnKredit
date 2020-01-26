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
    private var consoleOutputTool: ConsoleOutputTool
    private var configurationTool: ConfigurationTool

    private let arguments: [String]

    public init(configurationTool: ConfigurationTool, consoleOutputTool: ConsoleOutputTool, arguments: [String] = CommandLine.arguments)
    {
        self.consoleOutputTool = consoleOutputTool
        self.configurationTool = configurationTool
        self.arguments = arguments
    }

    public func run() throws
    {
        if CommandLine.arguments.contains("-help") {
            configurationTool.configurationModel.printUsage()
            return
        }
        
        // Test display of simple node data
        consoleOutputTool.displayNode(nodeIndex: 0, address: "0-127.0.0.1:8333", sentMessage: "Ping", receivedMessage: "Awaiting Pong", status: 2)
        
        consoleOutputTool.displayNode(nodeIndex: 1, address: "1-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutputTool.displayNode(nodeIndex: 2, address: "2-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Version", receivedMessage: "Awaiting VerAck", status: 1)
        
        consoleOutputTool.displayNode(nodeIndex: 3, address: "3-127.0.0.1:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutputTool.displayNode(nodeIndex: 4, address: "4-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 2)

        print("    Commandline parameters found:")
        if CommandLine.arguments.contains("-connectTo") {
            print("        -connectTo")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-connectTo" {
                    let data = arguments[index+1]
                    configurationTool.configurationModel.configurationDictionary[.connectTo] = data
                    let addresses = data.split(separator: ",")
                    print("            addresses: ")
                    for address in addresses {
                        print("                \(address)", terminator: "")
                        // Onlt add this address if it doesn't already exist
                        var needsAppending = true
                        for currentAddress in configurationTool.configurationModel.addressesArray {
                            if currentAddress == address {
                                print(" ( inside configuration file )", terminator: "")
                                needsAppending = false; break }
                        }
                        print("")
                        if needsAppending == true {
                            configurationTool.configurationModel.addressesArray.append(String(address))
                        }
                    }
                    print("")
                }
            }
        }
        if CommandLine.arguments.contains("-dataDirectory") {
            print("        -dataDirectory")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-dataDirectory" {
                    let path = arguments[index+1]
                    print("            path: ")
                    print("                \(path)")
                    print("")
                    configurationTool.configurationModel.configurationDictionary[.dataDirectory] = path
                }
            }
        }

        print("\n")
        
        print("configurationModel.configurationDictionary:")
        for configurationData in configurationTool.configurationModel.configurationDictionary {
            print("                \(configurationData.key) \(configurationData.value)")
        }
        print("")
        
        print("configurationModel.addressesArray:")
        for address in configurationTool.configurationModel.addressesArray {
            print("                \(address)")
        }
        print("")

        if arguments[1] == "echo server" {
            runEchoServer()
        }
    }
}
