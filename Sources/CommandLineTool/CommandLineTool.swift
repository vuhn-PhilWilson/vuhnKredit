//
//  File.swift
//  
//
//  Created by Phil Wilson on 18/1/20.
//

import Foundation
import CoreFoundation
import vuhnNetwork
import ConfigurationTool
import FileService

public final class CommandLineTool {
    private var configurationTool: ConfigurationTool
    private var connectedNodes = [String: NetworkUpdate]()
    private let arguments: [String]
    private var nodeManager = NodeManager()
    private var shuttingDown = false
    private var timer : DispatchSourceTimer?

    public init(configurationTool: ConfigurationTool, arguments: [String] = CommandLine.arguments) {
        self.configurationTool = configurationTool
        self.arguments = arguments
    }

    public func close() {
        shuttingDown = true
        nodeManager.close()
        shutDownTimer()
    }

    public func run() throws {
        
        print("\nconfiguration Dictionary\n    \(configurationTool.configurationModel.configurationDictionary)\n")

        configurationTool.configurationModel.configurationDictionary[.dataDirectory] = FileService.dataDirectoryPath().absoluteString
        
        
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
                    if configurationTool.configurationModel.configurationDictionary[.dataDirectory] != nil {
                        print("Commandline dataDirectory flag overrides configuration file")
                        print("dataDirectory was \(configurationTool.configurationModel.configurationDictionary[.dataDirectory]!)")
                    }
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
        
        if let seedAddresses = nodeManager.dnsSeedAddresses() {
            print("Found \(seedAddresses.count) seed Addresses")
            
            if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory],
                let dataPath = URL(string: "file://\(dataDirectory.replacingOccurrences(of: "\"", with: ""))") {
                print("dataDirectory = \(dataDirectory)")
                nodeManager.configure(with: seedAddresses)
                configurationTool.initialiseNodesFile(with: dataPath, nodes: nodeManager.nodes, forced: true)
                nodeManager.nodes.removeAll()
                
                // Connect to a few random seed addresses
                var addedNodes = 0
                let numberOfConnections = 30//seedAddresses.count
                while addedNodes < numberOfConnections && seedAddresses.count >= numberOfConnections {
                    let randomNode = Int.random(in: 0..<seedAddresses.count)
                    let node = seedAddresses[randomNode]
//                     let node = seedAddresses[addedNodes]
                    print("Adding node \(node) at index \(randomNode)")
                    if !configurationTool.configurationModel.addressesArray.contains(node) {
                        configurationTool.configurationModel.addressesArray.append(node)
                        addedNodes += 1
                    } else {
                        print("Found node collision for index \(randomNode)")
                    }
                }
            } else {
                if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory] {
                    print("error with creating URL with dataDirectory \(dataDirectory)")
                } else {
                    print("error with configurationDictionary dataDirectory")
                }
            }
        }
        
        nodeManager.configure(with: configurationTool.configurationModel.addressesArray, and: listeningPort ?? -1)

        print("Starting timer")
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        
        timer?.schedule(deadline: .now(), repeating: .seconds(5))
        timer?.setEventHandler
        {
            if self.shuttingDown == true {
                self.shutDownTimer()
                return
            }
            var countOfUnknownNodes = 0
            for node in self.nodeManager.nodes {
                print("node \(node.name) \(node.connectionType) last sent \(node.sentCommand) last received \(node.receivedCommand)")
            }
            for node in self.nodeManager.nodes {
                if node.receivedCommand == .unknown {
                    countOfUnknownNodes += 1
                }
            }
            print("\n\(self.nodeManager.nodes.count - countOfUnknownNodes) successful node connections\n\(countOfUnknownNodes) of \(self.nodeManager.nodes.count) nodes unknown\n")
        }
        timer?.resume()
        
        nodeManager.startListening()
        nodeManager.connectToOutboundNodes()
        
        // Keep console program alive
        // to allow netowrk streaming to continue
        CFRunLoopRun()
//        dispatchMain()
    }
    
    private func shutDownTimer() {
        print("shutDown Timer")
        self.timer?.cancel()
        self.timer?.setEventHandler {}
    }
}
