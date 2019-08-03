//
//  DateUtility.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/06Saturday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation

public enum DateUtil {
    case full
    case origin
    case display
    case displayDetail
    case graph
    case graphddMM
    case validate
    case hour
    case day
    case month
    case year

    public var formatter: DateFormatter {
        var formatter = DateFormatter()
        switch self {
        case .full:
            formatter.setLocalizedDateFormatFromTemplate("dateFull".localized)
        case .origin:
            formatter.setLocalizedDateFormatFromTemplate("dateOrigin".localized)
        case .display:
            formatter.setLocalizedDateFormatFromTemplate("dateDisplay".localized)
        case .displayDetail:
            formatter.setLocalizedDateFormatFromTemplate("dateDisplayDetail".localized)
        case .graph:
            formatter.setLocalizedDateFormatFromTemplate("dateGragh".localized)
        case .graphddMM:
            formatter.setLocalizedDateFormatFromTemplate("dateGraghddMM".localized)
        case .validate:
            formatter.setLocalizedDateFormatFromTemplate("dateForValidate".localized)
        case .hour:
            formatter.dateFormat = "h"
        case .day:
            formatter.dateFormat = "d"
        case .month:
            formatter.dateFormat = "M"
        case .year:
            formatter.dateFormat = "y"
        }
        return formatter
    }

    public static func now() -> Date {
        #if DEBUG
        return dateGetter?() ?? Date()
        #endif
        return Date()
    }
}

#if DEBUG
extension DateUtil {
    public static var dateGetter: (() -> Date)?
}
#endif

public extension Date {
    public var daysAgoString: String {
        let hourGap = DateUtil.now().timeIntervalSince(self) / (60 * 60)
        switch hourGap {
        case (let gap) where 24 <= gap:
            let days = Int(gap / 24)
            return "\(days)" + "daysAgo".localized
        default:
            return ""
        }
    }

    public func daysGap() -> Int {
        // FIXME: イケてない
        let string = DateUtil.origin.formatter.string(from: self)
        guard let date = DateUtil.origin.formatter.date(from: string) else { return 0 }
        let hourGap = Date().timeIntervalSince(date) / (60 * 60)
        switch hourGap {
        case (let gap) where 24 <= gap:
            let days = Int(gap / 24)
            return days
        default:
            return 0
        }
    }

    public var originDate: Date {
        let string = DateUtil.origin.formatter.string(from: self)

        if let originDate = DateUtil.origin.formatter.date(from: string) {
            return originDate
        } else {
            assertionFailure("couldn't get originDate from Date")
            return self
        }

    }

    public func oneDayBefore() -> Date {
        return self.addingTimeInterval(-TimeInterval.oneDay)
    }
}

public extension TimeInterval {

    public static let oneDay: TimeInterval = (60 * 60 * 24)
    public func displayText() -> String {
        let second = Int(self)
        let minutes = second / 60
        let hours = minutes / 60

        let secondGap = second % 60
        let minutesGap = minutes % 60

        switch ("\(hours)", "\(minutesGap)", "\(secondGap)") {
        case (let h, let m, let s):
            return h.timeFormat() + "hour".localized + " " + m.timeFormat() + "minutes".localized + " " + s.timeFormat() + "second".localized
        }
    }

    public func displayMunitesAndSecondText() -> String {
        let second = Int(self)
        let minutes = second / 60
        let secondGap = second % 60

        return minutes.toString.timeFormat() + "minutes".localized + " " + secondGap.toString.timeFormat() + "second".localized
    }

    public func displayOnlyMinutesText() -> String {
        return (self / 60 ).toInt.toString + "minutes".localized
    }

    public var hour: Int {
        let second = Int(self)
        let minutes = second / 60
        let hours = minutes / 60
        return hours
    }
}

public extension Date {
    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    public var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    public var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}