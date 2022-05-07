//
//  Schedule.swift
//  
//
//  Created by Marcela Auslenter on 07/05/2022.
//

import Foundation

struct Schedule: Codable {
    let hour: String
    let minute: String
    let task: String
    
    init(hour: String,
         minute: String,
         task: String) {
        self.hour = hour
        self.minute = minute
        self.task = task
    }
}
