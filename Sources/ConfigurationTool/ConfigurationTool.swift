//
//  ConfigurationTool.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation
import FileService
import vuhnNetwork

public final class ConfigurationTool {
    public let configurationModel = ConfigurationModel()
    
    public init() { }
    
    public func initialiseConfigurationFile() {
        let fileService = FileService()
        fileService.generateDefaultConfigurationFile()
        if let configurationDictionary = fileService.readConfigurationFile() {
            for key in configurationDictionary.keys.sorted() {
                guard let value = configurationDictionary[key] else { break }
                if ConfigurationModel.OptionType(value: key) == .connectTo {
                    configurationModel.configurationDictionary[.connectTo] = value
                    let addresses = value.split(separator: ",")
                    for address in addresses {
                        configurationModel.addressesArray.append(String(address))
                    }
                } else if ConfigurationModel.OptionType(value: key) == .dataDirectory {
                    configurationModel.configurationDictionary[.dataDirectory] = value
                }
            }
        }
    }
    
    // MARK: - Nodes
        
    public func initialiseNodesFile(with path: URL, nodes: [vuhnNetwork.Node]? = nil, forced: Bool = false) {
        let fileService = FileService()
        if let fileName = fileService.generateDefaultNodeFile(with: path, forced: forced),
            let nodes = nodes {
            addNodesToFile(with: fileName, nodes: nodes)
        }
    }
    
    public func addNodesToFile(with path: URL, nodes: [vuhnNetwork.Node]) {
        let fileService = FileService()
        for node in nodes {
            fileService.writeNodeDataToFile(with: path, node: node)
        }
    }
    
    public func readNodesFromFile(with path: URL) -> [vuhnNetwork.Node]? {
        let fileService = FileService()
        return fileService.readInNodes(with: path)
    }
    
    // MARK: - Headers

    public func initialiseHeadersFile(with path: URL, headers: [vuhnNetwork.Header], forced: Bool = false) {
        print("\(#function) [\(#line)] path = \(path)   headers.count = \(headers.count)")
        let fileService = FileService()
        if let fileName = fileService.generateDefaultHeaderFile(with: path, forced: forced) {
            addHeadersToFile(with: fileName, headers: headers)
        }
    }
    
    public func addHeadersToFile(with path: URL, headers: [vuhnNetwork.Header]) {
        print("\(#function) [\(#line)] path = \(path)   headers.count = \(headers.count)")
        if headers.count == 0 { return }
        let fileService = FileService()
        for header in headers {
//            print("\(#function) [\(#line)] \(index)")
            fileService.writeHeaderDataToFile(with: path, header: header)
        }
        
        // Make a sound whenever new headers have been written
//        #if os(macOS)
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "afplay")
//        process.arguments = ["/System/Library/Sounds/Ping.aiff -v 2"]
//        
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        try? process.run()
//        process.waitUntilExit()
//        #elseif os(Linux)
//        print("Play beep sound on *nix")
//        #endif
        
    }
    
    public func readHeadersFromFile(with path: URL) -> [vuhnNetwork.Header]? {
        print("\(#function) [\(#line)] path = \(path)")
        let fileService = FileService()
        return fileService.readInHeaders(with: path)
    }
}
