import XCTest
import class Foundation.Bundle
import ConfigurationTool

final class vuhnKreditTests: XCTestCase {
    
    
    func testExample() throws {
        XCTAssertEqual(ConfigurationModel.OptionType.connectTo.rawValue, "connectTo")
        XCTAssertEqual(ConfigurationModel.OptionType.dataDirectory.rawValue, "dataDirectory")
        XCTAssertEqual(ConfigurationModel.OptionType.help.rawValue, "help")
    }
    
    /*
     // To fix
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("vuhnKredit")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-help"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        print("output = \(output)")
        XCTAssertNotNil(output)
        XCTAssert(output!.contains("USAGE:"))
    }
*/
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
