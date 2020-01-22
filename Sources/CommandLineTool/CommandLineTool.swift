//
//  File.swift
//  
//
//  Created by Phil Wilson on 18/1/20.
//

import Foundation
import vuhnNetwork


public final class CommandLineTool
{
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments)
    {
        self.arguments = arguments
    }

    public func run() throws
    {
        if arguments.count != 2 {
            print("Usage: hello NAME")
        }
        else if arguments[1] == "echo server" {
            runEchoServer()
        }
        else
        {
            let name = arguments[1]
            sayHelloFromNetworkModule(name: name)
        }
    }
}
