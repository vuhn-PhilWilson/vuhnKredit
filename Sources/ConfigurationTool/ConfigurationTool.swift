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
}
