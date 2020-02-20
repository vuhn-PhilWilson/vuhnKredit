//
//  ConfigurationModel.swift
//  
//
//  Created by Phil Wilson on 24/1/20.
//

import Foundation

public class ConfigurationModel {
    
    public enum OptionType: String {
        case connectTo
        case dataDirectory
        case listeningPort
        case listeningPorts
        case help
        case unknown
        
        init(value: String) {
            switch value {
            case "connectTo": self = .connectTo
            case "dataDirectory": self = .dataDirectory
            case "listeningPort": self = .listeningPort
            case "listeningPorts": self = .listeningPorts
            case "help": self = .help
            default: self = .unknown
            }
        }
    }
    
    public var configurationDictionary = [OptionType: String]()
    public var addressesArray = [String]()
    public var listeningPort = "8333"
    
    public init() { }

    func getOption(_ option: String) -> (option:OptionType, value: String) {
      return (OptionType(value: option), option)
    }
    
    public func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        print("")
        print("USAGE:")
        print("user$ \(executableName) -command parameters")
        print("")
        print("COMMANDS:")
        print("    -connectTo <IPV4 Address>,<IPV6 Address>,...")
        print("    -dataDirectory <URL-to-directory-to-store-data>")
        print("    -help to show usage information")
        print("")
        print("EXAMPLES:")
        print("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888")
        print("user$ \(executableName) -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        print("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888 -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        print("user$ \(executableName) -listeningPort 8885")
        print("user$ \(executableName) -listeningPorts {\"network\":[8333,8334,8335,8336,8337],\"services\":{\"block\":[8338],\"transaction\":[8339],\"address\":[8340],\"utxo\":[8341],\"exchange\":[8342]}}")
        print("")
    }
}
