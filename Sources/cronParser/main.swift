import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "askjdfka", version: "0.0.1")
    
    @Argument(help: "Current hour") var currentTime: String = ""
    @Argument(help: "Executable file") var execFile: String = ""
    private var schedules = [Schedule]()
    
    mutating func run() throws {
        readFile()
    }
    
    private mutating func readFile() {
        var fileText = ""
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(execFile)
            
            do {
                fileText = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        let scheduleFileComponents = fileText.components(separatedBy: "\n")
        createSchedules(with: scheduleFileComponents)
    }
    
    private mutating func createSchedules(with scheduleFileComponents: [String]) {
        scheduleFileComponents.forEach { schedule in
            let scheduleItems = schedule.components(separatedBy: " ")
            schedules.append(Schedule(from: scheduleItems))
        }
        print("Schedules", schedules)
        getExpectedTimeForChronometer()
    }
    
    private func getExpectedTimeForChronometer() {
        let currentTime = CurrentTime(from: currentTime)
        print(currentTime)
    }
    
}

CronParser.main()
