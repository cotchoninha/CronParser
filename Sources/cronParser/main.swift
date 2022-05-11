import ArgumentParser
import Foundation

// read lines from txt input file
func readSTDIN () -> String? {
    var input:String?

    while let line = readLine() {
        if input == nil {
            input = line
        } else {
            input! += "\n" + line
        }
    }
    return input
}

var text: String?

// First argument is the project name and second will be the current hour in the format HH:MM
if CommandLine.arguments.count == 2 || CommandLine.arguments.contains(":") {
    text = readSTDIN()
}

// Create list of arguments with current hour
var arguments = Array(CommandLine.arguments.dropFirst())

// Append to the list of arguments the lines read from the txt file
if let text = text {
    arguments.insert(text, at: 0)
}

// Parse the arguments and run the program
var command = CronParser.parseOrExit(arguments)
do {
    try command.run()
} catch {
    CronParser.exit(withError: error)
}
