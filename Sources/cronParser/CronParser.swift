//
//  CronParser.swift
//  
//
//  Created by Marcela Auslenter on 09/05/2022.
//

import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "CronParser", version: "0.0.1")
    
    @Argument(help: "Schedules") private var schedules: String?
    @Argument(help: "Current hour") private var currentTime: String = ""
    
    mutating func run() throws {
        guard let schedules = schedules else { return }
        createSchedules(with: schedules.components(separatedBy: "\n"))
    }
   
    // Creates the scheduled tasks objects
    private mutating func createSchedules(with scheduleFileComponents: [String]) {
        var schedules = [Schedule]()
        scheduleFileComponents.forEach { schedule in
            let scheduleItems = schedule.components(separatedBy: " ")
            guard !scheduleItems.isEmpty, let first = scheduleItems.first, !first.isEmpty else { return }
            schedules.append(Schedule(from: scheduleItems))
        }
        getExpectedTimeForChronometer(with: schedules)
    }
    
    // Prints the correct expected times that the cronometer should run the task
    private func getExpectedTimeForChronometer(with schedules: [Schedule]) {
        guard !currentTime.isEmpty, currentTime.contains(":") else {
            print("The input current time is invalid")
            return
        }
        
        let currentTime = CurrentTime(from: currentTime)
        guard let currentHour = currentTime.hour, let currentMinutes = currentTime.minutes else {
            print("The input current time is invalid")
            return
        }
        
        schedules.forEach { schedule in
            let everyHourMinute = (schedule.isEveryHour, schedule.isEveryMinute)
            
            switch everyHourMinute {
            case (true, true):
                print("\(currentHour):\(currentMinutes) today - \(schedule.task)")
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
    
    
    private func outputForSpecificHourAndMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return
        }
        
        let timeStates = Schedule.timeStateForSpecificHourMinute(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(scheduleHour):\(scheduleMinutes) tomorrow - \(schedule.task)")
        case .after, .equal:
            print("\(scheduleHour):\(scheduleMinutes) today - \(schedule.task)")
        case .none:
            print("There's an error parsing the time")
        }
    }
    
    private func outputForSpecificHourEveryMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        let timeStates = Schedule.timeStateForSpecificHour(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(schedule.hour):00 tomorrow - \(schedule.task)")
        case .after:
            print("\(schedule.hour):00 today - \(schedule.task)")
        case .equal:
            print("\(schedule.hour):\(currentMinutes) today - \(schedule.task)")
        case .none:
            print("Error when parsing the time")
            
        }
    }
    
    private func outputForEveryHourSpecificMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        guard let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled minutes has an invalid format")
            return
        }
        
        let timeStates = Schedule.timeStateForSpecificMinutes(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            let hourValue = currentHour == 23 ? "00" : String(currentHour + 1)
            let dayValue = hourValue == "00" ? "tomorrow" : "today"
            print("\(hourValue):\(scheduleMinutes) \(dayValue) - \(schedule.task)")
        case .after:
            print("\(currentHour):\(scheduleMinutes) today - \(schedule.task)")
        case .equal:
            print("\(currentHour):\(scheduleMinutes) today - \(schedule.task)")
        case .none:
            print("There's an error parsing the time")
        }
    }
}
