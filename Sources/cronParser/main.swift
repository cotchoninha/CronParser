import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "askjdfka", version: "0.0.1")
    
    @Argument(help: "Current hour") var currentHour: String = ""
    @Argument(help: "Executable file") var execFile: String = ""
    private var fileText = ""
    
    mutating func run() throws {
        print(currentHour)
        readFile()
    }
    
    private mutating func readFile() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(execFile)
            
            do {
                fileText = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        print(fileText.components(separatedBy: "\n"))
    }
}

CronParser.main()
