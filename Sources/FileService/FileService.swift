//
//  FileService.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation

public class FileService {
    
    let fileManager = FileManager.default
    
    public init() { }
    
    public func generateDefaultConfigurationFile() {
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let appName = String(CommandLine.arguments[0]).split(separator: "/").last!
        let dataDirectory = libraryDirectory.appendingPathComponent("Application Support/\(appName)")
        print("dataDirectory = \(dataDirectory)")

        do
        {
            try FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }
            
        let defaultFileName = "configuration.ini"
        
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
        
        let filePath = dataDirectory.appendingPathComponent("\(defaultFileName)")
        if !fileManager.fileExists(atPath: filePath.path) {
            print("\(defaultFileName) doesn't exist. Creating file ...")
            fileManager.createFile(atPath: filePath.path, contents: defaultData, attributes: nil)
        }
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: dataDirectory.path)

            for item in items {
                print("Found \(item)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("failed to read directory \(dataDirectory)")
        }
        
    }
}
