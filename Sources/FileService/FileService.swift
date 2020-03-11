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

        let defaultDataString = "Addr,Attempts,LastAttempt,LastSuccess,Location,Latency,Services,Src,SrcServices,TimeStamp,ConnectFailure,ReceivePongFailure,ReceiveGetAddrResponseFailure\n"
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
    
    public func readInNodes(with filePath: URL) -> [vuhnNetwork.Node]? {
        let fileName = filePath.appendingPathComponent("\(defaultNodeFileName)")
        if !fileManager.fileExists(atPath: fileName.path) {
            return nil
        }
        
        guard let reader = LineReader(path: fileName.path) else {
            return nil // cannot open file
        }

        var nodes = [vuhnNetwork.Node]()
        var skipFirstLine = false
        for line in reader {
            if !skipFirstLine {
                skipFirstLine = true
                continue
            }
            
            enum Fields: Int {
                case Addr,Attempts,LastAttempt,LastSuccess,Location,Latency,Services,Src,SrcServices,TimeStamp,ConnectFailure,ReceivePongFailure,ReceiveGetAddrResponseFailure
            }
            // Addr,Attempts,LastAttempt,LastSuccess,Location,Latency,Services,Src,SrcServices,TimeStamp,ConnectFailure,ReceivePongFailure,ReceiveGetAddrResponseFailure
            // 0000:0000:0000:0000:0000:ffff:157.230.41.128:8333,1,1583649882,1583649882,¯\_(ツ)_/¯,4294967295,37,unknown,0,1583649984
            
            let splitLine = line.split(separator: ",")
            if splitLine.count != 13 {
                print("readInNodes: Error splitLine.count is not 13. It is \(splitLine.count)")
                continue
            }
            
            let addr = splitLine[Fields.Addr.rawValue]
            let attempts = splitLine[Fields.Attempts.rawValue]
            let lastAttempt = splitLine[Fields.LastAttempt.rawValue]
            let lastSuccess = splitLine[Fields.LastSuccess.rawValue]
            let location = splitLine[Fields.Location.rawValue]
            let latency = splitLine[Fields.Latency.rawValue]
            let services = splitLine[Fields.Services.rawValue]
            let src = splitLine[Fields.Src.rawValue]
            let srcServices = splitLine[Fields.SrcServices.rawValue]
            let timeStamp = splitLine[Fields.TimeStamp.rawValue]
            let connectFailure = splitLine[Fields.ConnectFailure.rawValue]
            let receivePongFailure = splitLine[Fields.ReceivePongFailure.rawValue]
            let receiveGetAddrResponseFailure = splitLine[Fields.ReceiveGetAddrResponseFailure.rawValue]
            
            
            let addressFieldSplit = splitLine[0].split(separator: ":")
            if addressFieldSplit.count == 9 {
                // This is an IPV6 address
                // Currently cannot connect to these addresses
//                print("readInNodes: Found IPV6 address \(addressFieldSplit.joined(separator: ":"))")
                continue
            }
            if addressFieldSplit.count != 8 {
                print("readInNodes: Error addressFieldSplit.count is not 8. It is \(addressFieldSplit.count) for \(addressFieldSplit)")
                continue
            }
            let address = addressFieldSplit[6]
            let port = addressFieldSplit[7]
            let newNode = Node(address: "\(address):\(port)")
            nodes.append(newNode)
//            print("readInNodes: Adding \(newNode.name)")
        }
        return nodes
    }
}

/// from https://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
/// Read text file line by line in efficient way
public class LineReader {
   public let path: String

   fileprivate let file: UnsafeMutablePointer<FILE>!

   init?(path: String) {
      self.path = path
      file = fopen(path, "r")
      guard file != nil else { return nil }
   }

   public var nextLine: String? {
      var line:UnsafeMutablePointer<CChar>? = nil
      var linecap:Int = 0
      defer { free(line) }
      return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
   }

   deinit {
      fclose(file)
   }
}

extension LineReader: Sequence {
   public func  makeIterator() -> AnyIterator<String> {
      return AnyIterator<String> {
         return self.nextLine
      }
   }
}
