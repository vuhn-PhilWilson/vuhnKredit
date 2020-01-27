//
//  FileService.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation

public class FileService {
    
    let fileManager = FileManager.default
    let defaultFileName = "configuration.ini"
    
    public init() { }
    
    public func generateDefaultConfigurationFile(forced: Bool = false) {
        do
        {
            try fileManager.createDirectory(at: dataDirectoryPath(), withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
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
        
        let filePath = dataDirectoryPath().appendingPathComponent("\(defaultFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
//            print("\(defaultFileName) doesn't exist. Creating file ...")
            fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
        } else {
//            print("\(defaultFileName) already exists.")
            if forced == true {
//                print("Overwriting \(defaultFileName)")
                fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
            }
        }
    }

    public func readConfigurationFile(configurationDirectory: URL? = nil) -> [String: String]? {
        let dataDirectory = configurationDirectory ?? dataDirectoryPath()
        let filePath = dataDirectory.appendingPathComponent("\(defaultFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
            print("\(defaultFileName) doesn't exist.")
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
                    print("\nError parsing file \"\(defaultFileName)\" line \(index)")
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
                    if var currentValue = configurationDictionary[key] {
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
            let items = try fileManager.contentsOfDirectory(atPath: dataDirectoryPath().path)

            for item in items {
                print("Found \(item)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("failed to read directory \(dataDirectoryPath())")
        }
    }
    
    private func dataDirectoryPath() -> URL {

        #if os(macOS)
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let appName = String(CommandLine.arguments[0]).split(separator: "/").last!
        let dataDirectory = libraryDirectory.appendingPathComponent("Application Support/\(appName)")
//        print("macOS: dataDirectory = \(dataDirectory)")
        return dataDirectory
        #else
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let appName = String(CommandLine.arguments[0]).split(separator: "/").last!
        let dataDirectory = homeDirectory.appendingPathComponent(".\(appName)")
//        print("linux: dataDirectory = \(dataDirectory)")
        return dataDirectory
        #endif
    }
}
