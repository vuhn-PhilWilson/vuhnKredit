//
//  File.swift
//  
//
//  Created by Phil Wilson on 18/1/20.
//

import Foundation
import vuhnNetwork


public final class CommandLineTool
{
    let consoleOutput = ConsoleOutput()
    let configurationModel = ConfigurationModel()

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments)
    {
        self.arguments = arguments
    }

    public func run() throws
    {
        consoleOutput.resetTerminal()
        consoleOutput.clearDisplay()
        
        if CommandLine.arguments.contains("-help") {
            configurationModel.printUsage()
            return
        }
        
        // Test display of simple node data
        consoleOutput.displayNode(nodeIndex: 0, address: "0-127.0.0.1:8333", sentMessage: "Ping", receivedMessage: "Awaiting Pong", status: 2)
        
        consoleOutput.displayNode(nodeIndex: 1, address: "1-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutput.displayNode(nodeIndex: 2, address: "2-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Version", receivedMessage: "Awaiting VerAck", status: 1)
        
        consoleOutput.displayNode(nodeIndex: 3, address: "3-127.0.0.1:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 0)
        
        consoleOutput.displayNode(nodeIndex: 4, address: "4-[ed12:ed12:ed12:ed12:ed12:ed12]:8333", sentMessage: "Pong", receivedMessage: "Inventory", status: 2)

        print("    Commandline parameters found:")
        if CommandLine.arguments.contains("-connectTo") {
            print("        -connectTo")
            for index in 0..<arguments.count {
                let command = arguments[index]
                if command == "-connectTo" {
                    let data = arguments[index+1]
                    configurationModel.configurationDictionary[.connectTo] = data
                    let addresses = data.split(separator: ",")
                    print("            addresses: ")
                    for address in addresses {
                        print("                \(address)")
                        configurationModel.addressesArray.append(String(address))
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
                    configurationModel.configurationDictionary[.dataDirectory] = path
                }
            }
        }

        print("\n")
        
        print("configurationModel.configurationDictionary:")
        for configurationData in configurationModel.configurationDictionary {
            print("                \(configurationData.key) \(configurationData.value)")
        }
        print("")
        
        print("configurationModel.addressesArray:")
        for address in configurationModel.addressesArray {
            print("                \(address)")
        }
        print("")

        if arguments[1] == "echo server" {
            runEchoServer()
        }
    }
}
