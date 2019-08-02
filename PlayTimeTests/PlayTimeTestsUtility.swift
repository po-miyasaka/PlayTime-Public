//
//  PlayTimeTestsUtility.swift
//  PlayTimeTests
//
//  Created by kazutoshi miyasaka on 2019/08/02.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

@testable import PlayTime
var meanTimesInSameDay: [MeanTime] {
    return [makeMeanTime(start: date(0)),
            makeMeanTime(start: date(10), status: MeanTimeStatus.injustice),
            makeMeanTime(start: date(30), status: MeanTimeStatus.shouldVaridate)]
}

var meanTimesConsectiveDays: [MeanTime] {
    return [makeMeanTime(start: date(10)),
            makeMeanTime(start: date(30).addingTimeInterval(TimeInterval.oneDay), status: MeanTimeStatus.injustice),
            makeMeanTime(start: date(50).addingTimeInterval(.oneDay * 2), status: MeanTimeStatus.shouldVaridate)]
}

var meanTimesOtherDays: [MeanTime] {
    return [makeMeanTime(start: date(0)),
            makeMeanTime(start: date(.oneDay * 2), status: MeanTimeStatus.shouldVaridate)]
}

var meanTimesAcross2Days: [MeanTime] {
    return [
        makeMeanTime(start: date(.oneDay - 10), timeInterval: 20),
        makeMeanTime(start: date((.oneDay * 2) - 10), timeInterval: 20),
        makeMeanTime(start: date((.oneDay * 3) - 10), timeInterval: 1500)
    ]
}

func makeMeanTime(start: Date, timeInterval: TimeInterval = 10, status: MeanTimeStatus = .varidated, dragonName: Dragon.Name = .momo) -> MeanTime {
    return MeanTime(start: start,
             end: start.addingTimeInterval(10),
             isValid: status,
             dragonName: dragonName)
}


var mockStory: Story {
    return Story.new(title: "テストストーリー")
}

func date(_ with: TimeInterval) -> Date {
    return Date(timeIntervalSinceReferenceDate: with)
}
