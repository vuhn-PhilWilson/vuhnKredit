//
//  ConsoleOutputTool.swift
//  
//
//  Created by Phil Wilson on 24/1/20.
//

import Foundation
import vuhnNetwork

// Example characters
// ┘┐┌└┼⎺⎻─⎼⎽├┤┴┬│▒

public enum OutputType {
    case info
    case error
}

public final class ConsoleOutputTool {
    
    public enum Status {
        case information
        case success
        case warning
        case error
    }

    enum TerminalCharacterAttribute {
        case reset      // 0    Reset all attributes
        case bright     // 1    Bright / Bold
        case dim        // 2    Dim
        case underscore // 4    Underscore
        case blink      // 5    Blink
        case reverse    // 7    Reverse
        case hidden     // 8    Hidden
        
        //              Foreground  Background
        case black      // 30           40
        case red        // 31           41
        case green      // 32           42
        case yellow     // 33           43
        case blue       // 34           44
        case magenta    // 35           45
        case cyan       // 36           46
        case white      // 37           47

        var foreground: Int {
            switch self {
            case .reset:        return 0
            case .bright:       return 1
            case .dim:          return 2
            case .underscore:   return 4
            case .blink:        return 5
            case .reverse:      return 7
            case .hidden:       return 8
            
            // Foreground Colours
            case .black:        return 30
            case .red:          return 31
            case .green:        return 32
            case .yellow:       return 33
            case .blue:         return 34
            case .magenta:      return 35
            case .cyan:         return 36
            case .white:        return 37
            }
        }
        
        var background: Int {
            switch self {
            case .reset:        return 0
            case .bright:       return 1
            case .dim:          return 2
            case .underscore:   return 4
            case .blink:        return 5
            case .reverse:      return 7
            case .hidden:       return 8
            
            // Background Colours
            case .black:        return 40
            case .red:          return 41
            case .green:        return 42
            case .yellow:       return 43
            case .blue:         return 44
            case .magenta:      return 45
            case .cyan:         return 46
            case .white:        return 47
            }
        }
    }
    
    public init() {
        resetTerminal()
        clearDisplay()
    }
    
    public func resetTerminal() {
        // Reset all terminal settings to default.
        print("\u{1B}c")
    }
    
    public func clearDisplay() {
        // Clear screen with the following attributes
        print("\u{1B}[\(TerminalCharacterAttribute.green.foreground);\(TerminalCharacterAttribute.black.background)m")
        print("\u{1B}[2J")
    }
    
    public func displayConsoleData(networkUpdate: NetworkUpdate, error: Error?, status: Status) {
        
    }
        
    public func displayInformation(networkUpdate: NetworkUpdate, error: Error?, status: Status) {

        let (foregroundColour, backgroundColour, specialAttributesStart, specialAttributesEnd) = attributesForStatus(status)

        var column = 0
        var line = 0
    
        // Draw table
        
        print("\u{1B}[\(foregroundColour);\(backgroundColour)m")
        line += 1
        print("\u{1B}[\(line);\(column)H ┌──────────────────┬───────────────────────────────────────┐ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │      \u{1B}[1mInformation\u{1B}[0;\(foregroundColour);\(backgroundColour)m │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │                  │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │                  │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H └──────────────────┴───────────────────────────────────────┘ ")
        line += 1
        
        // Insert data
        column = 23
        line = 2
        let networkUpdateType = networkUpdate.type.displayText()
        print("\u{1B}[\(line);\(column)H\(networkUpdateType)", terminator: "")

        column = 23
        line += 1
        if let message = networkUpdate.message1 {
            print("\u{1B}[\(line);\(column)H\(message)", terminator: "")
        }

        column = 23
        line += 1
        if let message = networkUpdate.message2 {
            print("\u{1B}[\(line);\(column)H\(specialAttributesStart)\(message)\(specialAttributesEnd)", terminator: "")
        }
        
        print("\u{1B}[\(16);\(0)H")
        print("\u{1B}[\(TerminalCharacterAttribute.green.foreground);\(TerminalCharacterAttribute.black.background)m")
        
    }
    
    private func attributesForStatus(_ status: Status) -> (Int, Int, String, String) {
        var foregroundColour = TerminalCharacterAttribute.green.foreground
        var backgroundColour = TerminalCharacterAttribute.black.background
         var specialAttributesStart = ""
         var specialAttributesEnd = ""
        if status == .success {
             foregroundColour = TerminalCharacterAttribute.white.foreground
             backgroundColour = TerminalCharacterAttribute.green.background
             specialAttributesStart = ""
             specialAttributesEnd = ""
        } else if status == .warning {
             foregroundColour = TerminalCharacterAttribute.black.foreground
             backgroundColour = TerminalCharacterAttribute.yellow.background
             specialAttributesStart = "\u{1B}[\(foregroundColour);\(backgroundColour);1;5;2m"
             specialAttributesEnd = "\u{1B}[0;\(foregroundColour);\(backgroundColour)m"
        } else if status == .error {
            foregroundColour = TerminalCharacterAttribute.yellow.foreground
            backgroundColour = TerminalCharacterAttribute.red.background
            specialAttributesStart = "\u{1B}[\(foregroundColour);\(backgroundColour);1;5;2m"
            specialAttributesEnd = "\u{1B}[0;\(foregroundColour);\(backgroundColour)m"
        }
        return (foregroundColour, backgroundColour, specialAttributesStart, specialAttributesEnd)
    }

    public func displayNode(nodeIndex: UInt8, connectionType: String, address: String, sentMessage: String, receivedMessage: String, status: Status) {
        let (foregroundColour, backgroundColour, specialAttributesStart, specialAttributesEnd) = attributesForStatus(status)
        
        print("sentMessage = \(sentMessage)")
        print("receivedMessage = \(receivedMessage)")
        
        let heightOfInformationSection: UInt = 10
        
        let height: Float32 = 5
        let width: Float32 = 63
        
        let q = (Float32(nodeIndex) / 2).rounded(.towardZero)
        let r = Float32(nodeIndex).truncatingRemainder(dividingBy: 2)
        let xOffset = UInt8(floor(r * width))
        let yOffset = UInt(floor(q * height))
        
        var column = xOffset
        var line = yOffset
        
        line += heightOfInformationSection
    
        // Draw table
        
        print("\u{1B}[\(foregroundColour);\(backgroundColour)m")
        line += 1
        print("\u{1B}[\(line);\(column)H ┌──────────────────┬───────────────────────────────────────┐ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │ \(connectionType) \u{1B}[1mAddress\u{1B}[0;\(foregroundColour);\(backgroundColour)m │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │     Sent Message │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H │ Received Message │                                       │ ")
        line += 1
        print("\u{1B}[\(line);\(column)H └──────────────────┴───────────────────────────────────────┘ ")
        line += 1
        
        // Insert data
        column = xOffset + 23 - UInt8(r)
        line = yOffset + 2
        line += heightOfInformationSection
        print("\u{1B}[\(line);\(column)H\(nodeIndex)-\(address)", terminator: "")

        column = xOffset + 23 - UInt8(r)
        line += 1
        print("\u{1B}[\(line);\(column)H\(sentMessage)", terminator: "")

        column = xOffset + 23 - UInt8(r)
        line += 1
        print("\u{1B}[\(line);\(column)H\(specialAttributesStart)\(receivedMessage)\(specialAttributesEnd)")
        
        print("\u{1B}[\(16);\(0)H")
        print("\u{1B}[\(TerminalCharacterAttribute.green.foreground);\(TerminalCharacterAttribute.black.background)m")
    }
    
    public func writeMessage(_ message: String, to: OutputType = .info) {
        switch to {
        case .info:
            print("\(message)")
        case .error:
            fputs("Error: \(message)]\n", stderr)
        }
    }
    
}
