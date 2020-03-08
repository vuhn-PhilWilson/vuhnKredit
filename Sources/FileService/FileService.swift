//
//  FileService.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation
import vuhnNetwork

public class FileService {
    
    let fileManager = FileManager.default
    let defaultConfigurationFileName = "configuration.ini"
    let defaultNodeFileName = "nodes.csv"
    
    public init() { }
    
    public func generateDefaultConfigurationFile(forced: Bool = false) {
        do {
            try fileManager.createDirectory(at: FileService.dataDirectoryPath(), withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
            return
        }
        
        let defaultDataString =
"""

# Configuration initialisation file

# items can be overridden on the commandline


# [connectTo]
# connectTo used to connect to this node only
# You can specify multiple node IP addresses
# Once address per line
    connectTo=[ed12:ed12:ed12:ed12:ed12:ed12]:8333
    connectTo=127.0.0.1:8333
    connectTo=localhost

# [dataDirectory]
# The directory location to store main data
    dataDirectory="/Users/<user>/Documents/Bitcoin/data"

"""
        let defaultData = defaultDataString.data(using: .utf8)
        
        let filePath = FileService.dataDirectoryPath().appendingPathComponent("\(defaultConfigurationFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
//            print("\(defaultConfigurationFileName) doesn't exist. Creating file ...")
            fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
        } else {
//            print("\(defaultConfigurationFileName) already exists.")
            if forced == true {
//                print("Overwriting \(defaultConfigurationFileName)")
                fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
            }
        }
    }

    public func readConfigurationFile(configurationDirectory: URL? = nil) -> [String: String]? {
        let dataDirectory = configurationDirectory ?? FileService.dataDirectoryPath()
        let filePath = dataDirectory.appendingPathComponent("\(defaultConfigurationFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
            print("\(defaultConfigurationFileName) doesn't exist.")
            return nil
        }
        
        // Read in contents
        var configurationDictionary = [String: String]()
        do {
            let data = try String(contentsOfFile: filePath.path, encoding: .utf8)
            
            // Filter out any comments ( #, ; ) or empty lines
            let lines = data.components(separatedBy: .newlines)
                .filter({
                    $0.first != ";" && $0.first != "#" && !$0.isEmpty
                })

            for (index, line) in lines.enumerated() {
                let splitLine = line.split(separator: "=")
                
                // Check for errors
                if splitLine.count != 2 {
                    print("\nError parsing file \"\(defaultConfigurationFileName)\" line \(index)")
                    if splitLine.count == 0 { continue }
                    print("\(line.trimmingCharacters(in: .whitespacesAndNewlines))")
                    for _ in 0..<splitLine[0].trimmingCharacters(in: .whitespacesAndNewlines).count+1 {
                        print(" ", terminator: "")
                    }
                    for _ in 0..<splitLine[1].count {
                        print("~", terminator: "")
                    }
                    print("^")
                    print("Only one '=' per line allowed\n")
                    continue
                }
                
                // Add into dictionary
                if let first = splitLine.first,
                    let second = splitLine.last {
                    let key = String(first).trimmingCharacters(in: .whitespacesAndNewlines)
                    var value = String(second).trimmingCharacters(in: .whitespacesAndNewlines)
                    if let currentValue = configurationDictionary[key] {
                        value = "\(currentValue),\(value)"
                    }
                    configurationDictionary[key] = value
                }
            }
        } catch {
            print(error)
            return nil
        }
        return configurationDictionary
    }

    public func printDataDirectoryContents() {
        do {
            let items = try fileManager.contentsOfDirectory(atPath: FileService.dataDirectoryPath().path)

            for item in items {
                print("Found \(item)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("failed to read directory \(FileService.dataDirectoryPath())")
        }
    }
    
    public static func dataDirectoryPath() -> URL {

        #if os(macOS)
        let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let appName = String(CommandLine.arguments[0]).split(separator: "/").last!
        let dataDirectory = libraryDirectory.appendingPathComponent("Application Support/\(appName)")
        print("macOS: dataDirectory = \(dataDirectory)")
        return dataDirectory
        #else
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let appName = String(CommandLine.arguments[0]).split(separator: "/").last!
        let dataDirectory = homeDirectory.appendingPathComponent(".\(appName)")
        print("linux: dataDirectory = \(dataDirectory)")
        return dataDirectory
        #endif
    }
    
    // MARK: - Data Directory
    
    // MARK: - Node Data
        
    public func generateDefaultNodeFile(with path: URL, forced: Bool = false) -> URL? {
        do {
            try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
            return nil
        }
        
        let defaultDataString = "Addr,Attempts,LastAttempt,LastSuccess,Location,Latency,Services,Src,SrcServices,TimeStamp\n"
        let defaultData = defaultDataString.data(using: .utf8)
        
        let filePath = path.appendingPathComponent("\(defaultNodeFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
            print("\(defaultNodeFileName) doesn't exist. Creating file ...")
            fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
        } else {
            print("\(defaultNodeFileName) already exists.")
            if forced == true {
                print("Overwriting \(defaultNodeFileName)")
                fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
            }
        }
        return filePath
    }
    
    public func writeNodeDataToFile(with filePath: URL, node: vuhnNetwork.Node) {
        print("Writing node \(node.name) data to file")
        if !fileManager.fileExists(atPath: filePath.path) {
            return
        }
        
        let nodeFileData = node.serializeForDisk()
        
        if let fileHandle = FileHandle(forWritingAtPath: filePath.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(nodeFileData)
        } else {
            print("Can't open fileHandle")
        }
    }
}
