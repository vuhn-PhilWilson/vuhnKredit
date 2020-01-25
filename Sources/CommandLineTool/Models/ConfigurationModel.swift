//
//  ConfigurationModel.swift
//  
//
//  Created by Phil Wilson on 24/1/20.
//

import Foundation

class ConfigurationModel {
    let consoleOutput = ConsoleOutput()
    
    enum OptionType: String {
        case connectTo = "-connectTo"
        case dataDirectory = "-dataDirectory"
        case help = "-help"
        case unknown
        
        init(value: String) {
            switch value {
            case "-connectTo": self = .connectTo
            case "-dataDirectory": self = .dataDirectory
            case "-help": self = .help
            default: self = .unknown
            }
        }
    }
    
    var configurationDictionary = [OptionType: String]()
    var addressesArray = [String]()

    func getOption(_ option: String) -> (option:OptionType, value: String) {
      return (OptionType(value: option), option)
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        consoleOutput.writeMessage("")
        consoleOutput.writeMessage("USAGE:")
        consoleOutput.writeMessage("user$ \(executableName) -command parameters")
        consoleOutput.writeMessage("")
        consoleOutput.writeMessage("COMMANDS:")
        consoleOutput.writeMessage("    -connectTo <IPV4 Address>,<IPV6 Address>,...")
        consoleOutput.writeMessage("    -dataDirectory <URL-to-directory-to-store-data>")
        consoleOutput.writeMessage("    -help to show usage information")
        consoleOutput.writeMessage("")
        consoleOutput.writeMessage("EXAMPLES:")
        consoleOutput.writeMessage("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888")
        consoleOutput.writeMessage("user$ \(executableName) -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        consoleOutput.writeMessage("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888 -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        consoleOutput.writeMessage("")
    }
}
