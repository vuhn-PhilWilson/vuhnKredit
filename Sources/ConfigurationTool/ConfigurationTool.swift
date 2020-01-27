//
//  ConfigurationTool.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation
import FileService

public final class ConfigurationTool
{
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
}
