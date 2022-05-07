import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "askjdfka", version: "0.0.1")
    
    @Argument(help: "Current hour") var currentTime: String = "16:10"
    @Argument(help: "Executable file") var execFile: String = "cat.txt"
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
        guard let currentHour = currentTime.hour, let currentMinutes = currentTime.minutes else {
            print("The input current time is invalid")
            return
        }
        
        schedules.forEach { schedule in
            let everyHourMinute = (schedule.isEveryHour, schedule.isEveryMinute)
            print("everyHourMinute ", everyHourMinute)
            
            switch everyHourMinute {
            case (true, true):
                print("true, true")
                print("\(currentHour):\(currentMinutes) today")
            case (false, true):
                // if schedule specific hour and every minute, I need to check:
                // - if schedule hour after current hour print("\(schedule.hour):\(00) today)
                // - if schedule hour == current hour, print("\(schedule.hour):\(current.minute) today)
                // - if schedule hour before current hour, print("\(schedule.hour):\(00) tomorrow)
                print("false, true")
            case (true, false):
                print("true, false")
                //CHECK IF MIDNIGHT
                // if schedule every hour and specific minute, I need to check:
                // - if schedule minute > current minute print("\(current.hour):\(schedule.minute) today)
                // - if schedule minute == current minute, print("\(schedule.hour):\(schedule.minute) today)
                // - if schedule minute < current minute, print("\(current.hour + 1):\(schedule.minute) tomorrow)
            case (false, false):
                // if both are ran specific hour and minute I need to check:
                // - if schedule time after current time print("\(schedule.hour):\(schedule.minute) tomorrow)
                // - if current time == schedule time, print("\(schedule.hour):\(schedule.minute) today)
                // - if schedule time before current time, print("\(schedule.hour):\(schedule.minute) today)
                print("false, false")
            }
        }
    }

}

CronParser.main()
