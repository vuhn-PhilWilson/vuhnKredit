
import CommandLineTool
import ConfigurationTool
import ConsoleOutputTool

let configurationTool = ConfigurationTool()
let consoleOutputTool = ConsoleOutputTool()

let commandLineTool = CommandLineTool(configurationTool: configurationTool, consoleOutputTool: consoleOutputTool)

do {
    try commandLineTool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
