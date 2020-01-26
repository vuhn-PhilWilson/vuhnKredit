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
    
    public init() {
        let fileService = FileService()
        fileService.generateDefaultConfigurationFile()
        if let configurationDictionary = fileService.readConfigurationFile() {
            print("Read configuration dictionary")
            for key in configurationDictionary.keys.sorted() {
                guard let value = configurationDictionary[key] else { break }
                print("      \(key) : \(value)")

                if ConfigurationModel.OptionType(value: key) == .connectTo {
                    configurationModel.configurationDictionary[.connectTo] = value
                    let addresses = value.split(separator: ",")
                    print("            addresses: ")
                    for address in addresses {
                        print("                \(address)")
                        configurationModel.addressesArray.append(String(address))
                    }
                } else if ConfigurationModel.OptionType(value: key) == .dataDirectory {
                    configurationModel.configurationDictionary[.dataDirectory] = value
                }
            }
        }
    }
}
