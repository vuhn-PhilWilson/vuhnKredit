
import CommandLineTool
import ConfigurationTool
import ConsoleOutputTool

let configurationTool = ConfigurationTool()
configurationTool.configurationModel.initialiseConsoleOutput()
configurationTool.initialiseConfigurationFile()

let commandLineTool = CommandLineTool(configurationTool: configurationTool)

do {
    try commandLineTool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
