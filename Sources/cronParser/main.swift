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
            
            switch everyHourMinute {
            case (true, true):
                print("true, true")
                //
                print("\(currentHour):\(currentMinutes) today")
            case (false, true):
                print("false, true")
            case (true, false):
                print("true, false")
                //CHECK IF MIDNIGHT
                // if schedule every hour and specific minute, I need to check:
                // - if schedule minute > current minute print("\(current.hour):\(schedule.minute) today)
                // - if schedule minute == current minute, print("\(schedule.hour):\(schedule.minute) today)
                // - if schedule minute < current minute, print("\(current.hour + 1):\(schedule.minute) tomorrow)
            case (false, false):
                outputForSpecificHourAndMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
                
                print("false, false")
            }
        }
    }

    
    func outputForSpecificHourAndMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        // - if schedule time > current time print("\(schedule.hour):\(schedule.minute) today)
        // - if current time == schedule time, print("\(schedule.hour):\(schedule.minute) today)
        // - if schedule time < current time, print("\(schedule.hour):\(schedule.minute) tomorrow)
        
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return
        }
        
        if scheduleHour == currentHour, scheduleMinutes == currentMinutes {
            print("\(schedule.hour):\(schedule.minutes) today")
        } else if currentHour == scheduleHour {
            if currentMinutes > scheduleMinutes {
                print("\(scheduleHour):\(scheduleMinutes) today")
            } else {
                print("\(scheduleHour):\(scheduleMinutes) tomorrow")
            }
        } else if currentHour > scheduleHour {
            print("\(scheduleHour):\(scheduleMinutes) tomorrow")
        } else if currentHour < scheduleHour {
            print("\(scheduleHour):\(scheduleMinutes) today")
        }
    }
    
    func outputForSpecificHourEveryMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        // - if schedule hour after current hour print("\(schedule.hour):\(00) today)
        // - if schedule hour == current hour, print("\(schedule.hour):\(current.minute) today)
        // - if schedule hour before current hour, print("\(schedule.hour):\(00) tomorrow)
        
    }
    
}

CronParser.main()
