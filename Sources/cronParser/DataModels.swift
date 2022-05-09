//
//  DataModels.swift
//  
//
//  Created by Marcela Auslenter on 07/05/2022.
//

import Foundation

/// A Schedule will retain the indication of the hours and minutes that a task needs to run and the description of that periodicity.
struct Schedule: Codable {
    let hour: String
    let minutes: String
    let task: String
    
    init(from scheduleItems: [String]) {
        self.hour = scheduleItems[1]
        self.minutes = scheduleItems[0]
        self.task = scheduleItems[2]
    }
    
    var isEveryHour: Bool {
        hour == "*" ? true : false
    }
    
    var isEveryMinute: Bool {
        minutes == "*" ? true : false
    }
}

// The Schedule methods will return the state of the time comparing the scheduled time with the current time and return before, after, equal or none, based on the type of task.
extension Schedule {

    static func timeStateForSpecificHourMinute(
        from schedule: Self,
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
        from schedule: Self,
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
        from schedule: Self,
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

/// Current time represents the hours and the minutes of the input current time
struct CurrentTime: Codable {
    let hour: Int?
    let minutes: Int?
    
    init(from currentTime: String) {
        let timeElements = currentTime.components(separatedBy: ":")
        self.hour = Int(timeElements[0])
        self.minutes = Int(timeElements[1])
    }
}

/// Types of time states when comparing the scheduled hour with the current hour and determine if it's before after or equal.
enum TimeStates {
    case before
    case after
    case equal
    case none
}
