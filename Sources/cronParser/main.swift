import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "askjdfka", version: "0.0.1")
    
    @Argument(help: "Current hour") var currentTime: String = "23:46"
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
        createSchedules(with: fileText.components(separatedBy: "\n"))
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
                print("\(currentHour):\(currentMinutes) today")
            case (false, true):
                outputForSpecificHourEveryMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            case (true, false):
                outputForEveryHourSpecificMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            case (false, false):
                outputForSpecificHourAndMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            }
        }
    }

    
    func outputForSpecificHourAndMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return
        }
        
        let timeStates = Int.timeStateForSpecificHourMinute(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(scheduleHour):\(scheduleMinutes) tomorrow")
        case .after, .equal:
            print("\(scheduleHour):\(scheduleMinutes) today")
        case .none:
            print("There's an error parsing the time")
        }
    }
    
    func outputForSpecificHourEveryMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        let timeStates = Int.timeStateForSpecificHour(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(schedule.hour):00 tomorrow")
        case .after:
            print("\(schedule.hour):00 today")
        case .equal:
            print("\(schedule.hour):\(currentMinutes) today")
        case .none:
            print("There's an error parsing the time")

        }
    }
    
    func outputForEveryHourSpecificMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        guard let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled minutes has an invalid format")
            return
        }
        
        let timeStates = Int.timeStateForSpecificMinutes(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            let hourValue = currentHour == 23 ? "00" : String(currentHour + 1)
            let dayValue = hourValue == "00" ? "tomorrow" : "today"
            print("\(hourValue):\(scheduleMinutes) \(dayValue)")
        case .after:
            print("\(currentHour):\(scheduleMinutes) today")
        case .equal:
            print("\(currentHour):\(scheduleMinutes) today")
        case .none:
            print("There's an error parsing the time")
        }
    }
}

extension Int {
    
    static func timeStateForSpecificHourMinute(
        from schedule: Schedule,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return .none
        }
        
        if scheduleHour == currentHour, scheduleMinutes == currentMinutes {
            return .equal
        } else if scheduleHour == currentHour {
            if scheduleMinutes < currentMinutes {
                return .before
            } else {
                return .after
            }
        } else if scheduleHour < currentHour {
            return .before
        } else if scheduleHour > currentHour {
            return .after
        }
        return .none
    }
    
    static func timeStateForSpecificHour(
        from schedule: Schedule,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleHour = Int(schedule.hour) else {
            print("The Scheduled hour has an invalid format")
            return .none
        }

        if scheduleHour == currentHour {
            return .equal
        } else if scheduleHour > currentHour {
            return .after
        } else if scheduleHour < currentHour {
            return .before
        }
        return .none
    }
    
    static func timeStateForSpecificMinutes(
        from schedule: Schedule,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled minutes has an invalid format")
            return .none
        }

        if scheduleMinutes == currentMinutes {
            return .equal
        } else if scheduleMinutes > currentMinutes {
            return .after
        } else if scheduleMinutes < currentMinutes {
            return .before
        }
        return .none
    }
    
}

CronParser.main()
