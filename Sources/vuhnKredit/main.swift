
import Foundation
import CommandLineTool
import ConfigurationTool

let configurationTool = ConfigurationTool()
configurationTool.initialiseConfigurationFile()

let commandLineTool = CommandLineTool(configurationTool: configurationTool)

private func setUpInterruptHandling() -> DispatchSourceSignal {
    print("setUp Interrupt Handling")
    // Make sure the ctrl+c signal does not terminate the application.
    signal(SIGINT, SIG_IGN)

    let signalInteruptSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    signalInteruptSource.setEventHandler {
        print("Shutting down ...")
        commandLineTool.close()
        exit(0)
    }
    return signalInteruptSource
}


let signalInteruptHandler = setUpInterruptHandling()
signalInteruptHandler.resume()

do {
    try commandLineTool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
