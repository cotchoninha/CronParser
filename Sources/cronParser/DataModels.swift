//
//  DataModels.swift
//  
//
//  Created by Marcela Auslenter on 07/05/2022.
//

import Foundation

struct Schedule: Codable {
    let hour: String
    let minutes: String
    let task: String
    
    init(from scheduleItems: [String]) {
        self.hour = scheduleItems[0]
        self.minutes = scheduleItems[1]
        self.task = scheduleItems[2]
    }
    
    var isEveryHour: Bool {
        hour == "*" ? true : false
    }
    
    var isEveryMinute: Bool {
        minutes == "*" ? true : false
    }
}

struct CurrentTime: Codable {
    let hour: String
    let minutes: String
    
    init(from currentTime: String) {
        let timeElements = currentTime.components(separatedBy: ":")
        self.hour = timeElements[0]
        self.minutes = timeElements[1]
    }
}
