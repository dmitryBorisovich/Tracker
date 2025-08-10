import Foundation

enum DaysOfWeek: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
//    var name: String {
//        switch self {
//        case .monday: return "Понедельник"
//        case .tuesday: return "Вторник"
//        case .wednesday: return "Среда"
//        case .thursday: return "Четверг"
//        case .friday: return "Пятница"
//        case .saturday: return "Суббота"
//        case .sunday: return "Воскресенье"
//        }
//    }
//    
//    var shortName: String {
//        switch self {
//        case .monday: return "Пн"
//        case .tuesday: return "Вт"
//        case .wednesday: return "Ср"
//        case .thursday: return "Чт"
//        case .friday: return "Пт"
//        case .saturday: return "Сб"
//        case .sunday: return "Вс"
//        }
//    }
    
    private var baseKey: String {
        switch self {
        case .monday: return "monday"
        case .tuesday: return "tuesday"
        case .wednesday: return "wednesday"
        case .thursday: return "thursday"
        case .friday: return "friday"
        case .saturday: return "saturday"
        case .sunday: return "sunday"
        }
    }
    
    var name: String {
        let key = "weekday.\(baseKey).full"
        return NSLocalizedString(key, comment: "Full weekday name")
    }
    
    var shortName: String {
        let key = "weekday.\(baseKey).short"
        return NSLocalizedString(key, comment: "Short weekday name")
    }
}
