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

public final class CommandLineTool: NodeManagerDelegate {
    private var configurationTool: ConfigurationTool
    private var connectedNodes = [String: NetworkUpdate]()
    private let arguments: [String]
    private var nodeManager = NodeManager()
    private var shuttingDown = false
    private var timer : DispatchSourceTimer?

    public init(configurationTool: ConfigurationTool, arguments: [String] = CommandLine.arguments) {
        self.configurationTool = configurationTool
        self.arguments = arguments
        nodeManager.nodeManagerDelegate = self
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

        var storedNodes: [vuhnNetwork.Node]?
        var storedHeaders: [vuhnNetwork.Header]?
        if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory],
            let dataPath = URL(string: "\(dataDirectory.replacingOccurrences(of: "\"", with: ""))") {
//            print("dataDirectory = \(dataDirectory)")
//            print("dataPath = \(dataPath)")

            
            storedHeaders = configurationTool.readHeadersFromFile(with: dataPath)
            if let storedHeaders = storedHeaders {
                print("Found \(storedHeaders.count) stored headers in \(dataPath)")
            } else {
                print("No headers found in \(dataPath)")
                // Clear out headers data
                configurationTool.initialiseHeadersFile(with: dataPath, headers: [], forced: true)
            }
        
            storedNodes = configurationTool.readNodesFromFile(with: dataPath)
            if let storedNodes = storedNodes {
                print("Found \(storedNodes.count) stored nodes in \(dataPath)")
            } else {
                print("No nodes found in \(dataPath)")
            }
        }
        
        // If there are stored nodes then use them
        var selectedNodes: [vuhnNetwork.Node]?
        var allNodes: [(TimeInterval, vuhnNetwork.Node)]?
        if let storedNodes = storedNodes {
//            selectedNodes = getRandomNodes(from: storedNodes, for: 25)
            selectedNodes = getRandomNodes(from: storedNodes, for: 10)
//             selectedNodes = getRandomNodes(from: storedNodes, for: 50)
            allNodes = storedNodes.map { node in
                return (TimeInterval(node.lastSuccess), node)
            }
            if let allNodes = allNodes {
                let (_, firstNode) = allNodes[0]
                print("allNodes \(allNodes.count)")
                print("firstNode lastSuccess \(firstNode.lastSuccess)")
                print("firstNode name \(firstNode.name)")
            }
        } else {
            // Otherwise, nodes must be obtained from DNS seeders
            if let seedAddresses = nodeManager.dnsSeedAddresses() {
                print("Found \(seedAddresses.count) seed Addresses")
                
                if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory],
                    let dataPath = URL(string: "\(dataDirectory.replacingOccurrences(of: "\"", with: ""))") {
//                        print("dataPath = \(dataPath)")
//                        print("dataDirectory = \(dataDirectory)")
                    nodeManager.configure(with: seedAddresses)
                    configurationTool.initialiseNodesFile(with: dataPath, nodes: nodeManager.nodes, forced: true)
                    nodeManager.nodes.removeAll()
                    
                    // Connect to a few random seed addresses
                    var addedNodes = 0
                    let numberOfConnections = 5//seedAddresses.count
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
        }
        
        if let selectedNodes = selectedNodes {
            print("configuring nodeManager with \(selectedNodes.count) selectedNodes")
            nodeManager.configure(with: selectedNodes,
                                  and: 8333,
                                  allNodes: allNodes,
                                  allHeaders: storedHeaders)
        } else {
            print("configuring nodeManager with \(configurationTool.configurationModel.addressesArray.count) addressesArray")
            nodeManager.configure(with: configurationTool.configurationModel.addressesArray,
                                  and: listeningPort ?? -1,
                                  allNodes: allNodes,
                                  allHeaders: storedHeaders)
        }

        print("Starting console display update timer")
        
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
                print("node \(node.nameShortened.padding(toLength: 70, withPad: " ", startingAt: 0))\t\(node.connectionType)\tlast sent \(node.sentCommand.rawValue.padding(toLength: 12, withPad: " ", startingAt: 0))\tlast received \(node.receivedCommand.rawValue.padding(toLength: 12, withPad: " ", startingAt: 0))")
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
    
    private func getRandomNodes(from seedNodes:[vuhnNetwork.Node], for count: Int) -> [vuhnNetwork.Node]? {
        print("get \(count) Random Nodes from \(seedNodes.count) seed nodes")
        
        // A few sanity checks
        // At least 10 nodes must be available
        // The requested number of nodes must be within this array
        // Cannot request more than 10% of node list
        // i.e. for a list of 1,000 nodes, cannot request more than 100
        guard seedNodes.count > 10 else { return nil}
        
        var maxCount = count
        if count >= seedNodes.count / 2 {
            maxCount = seedNodes.count / 2
        }
        var selectedNodes = [vuhnNetwork.Node]()

        // Connect to a few random seed addresses
        var addedNodes = 0
        while addedNodes < maxCount {
            let randomNode = Int.random(in: 0..<seedNodes.count)
            let node = seedNodes[randomNode]
//            let node = seedNodes[addedNodes]
            if !selectedNodes.contains(node) {
                selectedNodes.append(node)
                addedNodes += 1
            } else {
                print("Found node collision for index \(randomNode)")
            }
        }
        
        return selectedNodes
    }
    
    private func shutDownTimer() {
        print("shutDown console display Timer")
        self.timer?.cancel()
        self.timer?.setEventHandler {}
    }
    
    // MARK: - NodeManager Delegate
    
    public func addressesUpdated(for nodes: [Node]) {
        print("Updating \(nodes.count) node addresses")
        if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory],
            let dataPath = URL(string: "file://\(dataDirectory.replacingOccurrences(of: "\"", with: ""))") {
//            print("dataDirectory = \(dataDirectory)")
            
            /*
            let storedNodes = configurationTool.readNodesFromFile(with: dataPath)
            if let storedNodes = storedNodes {
                print("Found \(storedNodes.count) stored nodes in \(dataPath)")
            } else {
                print("No nodes found in \(dataPath)")
            }
            */
            /*
            for index in 0..<storedNodes.count {
                let node = storedNodes[index]
                if !self.networkAddresses.contains(where: { (arg0) -> Bool in
                    let (_, networkAddressToCheck) = arg0
                    return networkAddressToCheck.address == networkAddress.address
                }) {
                    let newNode = Node(address: networkAddress.address, port: networkAddress.port)
                    newNode.services = networkAddress.services
                    newNode.attemptsToConnect = 0
                    newNode.lastAttempt = 0
                    newNode.lastSuccess = 0
                    newNode.src = sourceNode.name
                    newNode.srcServices = sourceNode.services
                    self.networkAddresses.append((timestamp, newNode))
                    additionsCount += 1
                }
            }
            */
            
            // Re-generate nodes.csv file from scratch with supplied data
            configurationTool.initialiseNodesFile(with: dataPath, nodes: nodes, forced: true)
        }
    }
    
    public func blockHeadersUpdated(for headers: [Header]) {
        print("Updating \(headers.count) headers")
        
        if let dataDirectory = configurationTool.configurationModel.configurationDictionary[.dataDirectory],
            let dataPath = URL(string: "file://\(dataDirectory.replacingOccurrences(of: "\"", with: ""))") {
            
            let filePath = dataPath.appendingPathComponent("\(FileService.defaultHeaderFileName)")
            configurationTool.addHeadersToFile(with: filePath, headers: headers)
        }
    }
}
