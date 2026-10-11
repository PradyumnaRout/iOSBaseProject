//
//  String + Extension.swift
//  FreshMorning
//
//  Created by hb on 14/09/26.
//

import Foundation

extension String {
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        
        guard let date = formatter.date(from: self) else {
            return ""
        }
        
        let seconds = Int(Date().timeIntervalSince(date))
        
        // Future date / just now
        guard seconds > 0 else {
            return "Just now"
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 365 * day
        
        switch seconds {
        case 0..<minute:
            return "Just now"
            
        case minute..<hour:
            return "\(seconds / minute)m ago"
            
        case hour..<day:
            return "\(seconds / hour)h ago"
            
        case day..<week:
            return "\(seconds / day)d ago"
            
        case week..<month:
            return "\(seconds / week)w ago"
            
        case month..<year:
            return "\(seconds / month)mo ago"
            
        default:
            return "\(seconds / year)y ago"
        }
    }
}
