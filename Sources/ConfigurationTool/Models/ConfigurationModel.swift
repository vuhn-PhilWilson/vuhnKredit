//
//  ConfigurationModel.swift
//  
//
//  Created by Phil Wilson on 24/1/20.
//

import Foundation
import ConsoleOutputTool

public class ConfigurationModel {
    public var consoleOutputTool: ConsoleOutputTool?
    
    public enum OptionType: String {
        case connectTo = "connectTo"
        case dataDirectory = "dataDirectory"
        case help = "help"
        case unknown
        
        init(value: String) {
            switch value {
            case "connectTo": self = .connectTo
            case "dataDirectory": self = .dataDirectory
            case "help": self = .help
            default: self = .unknown
            }
        }
    }
    
    public var configurationDictionary = [OptionType: String]()
    public var addressesArray = [String]()
    
    public init() { }
    
    public func initialiseConsoleOutput() {
        self.consoleOutputTool = ConsoleOutputTool()
    }

    func getOption(_ option: String) -> (option:OptionType, value: String) {
      return (OptionType(value: option), option)
    }
    
    public func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        consoleOutputTool?.writeMessage("")
        consoleOutputTool?.writeMessage("USAGE:")
        consoleOutputTool?.writeMessage("user$ \(executableName) -command parameters")
        consoleOutputTool?.writeMessage("")
        consoleOutputTool?.writeMessage("COMMANDS:")
        consoleOutputTool?.writeMessage("    -connectTo <IPV4 Address>,<IPV6 Address>,...")
        consoleOutputTool?.writeMessage("    -dataDirectory <URL-to-directory-to-store-data>")
        consoleOutputTool?.writeMessage("    -help to show usage information")
        consoleOutputTool?.writeMessage("")
        consoleOutputTool?.writeMessage("EXAMPLES:")
        consoleOutputTool?.writeMessage("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888")
        consoleOutputTool?.writeMessage("user$ \(executableName) -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        consoleOutputTool?.writeMessage("user$ \(executableName) -connectTo 127.0.0.1,192.168.0.10:8333.[::1]:8888 -dataDirectory \"/Users/<user>/Documents/Bitcoin/data/\"")
        consoleOutputTool?.writeMessage("")
    }
}
