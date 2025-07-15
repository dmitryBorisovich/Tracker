import UIKit

final class ScheduleMarshalling {
    
    func scheduleString(from schedule: [DaysOfWeek]) -> String {
        schedule.map { String($0.rawValue) }.joined(separator: ",")
    }

    func schedule(from string: String) -> [DaysOfWeek] {
        string
            .components(separatedBy: ",").compactMap { Int($0) }
            .compactMap {
                DaysOfWeek(rawValue: $0)
            }
    }
}
