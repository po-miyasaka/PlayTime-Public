//
//  MeanTime.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift

struct MeanTime: Codable {
    let start: Date
    var end: Date
    var isValid: MeanTimeStatus = .shouldVaridate
    var dragonName: Dragon.Name

    var playTime: TimeInterval {
        return end.timeIntervalSince(start)
    }

    func copy(
        start: Date? = nil,
        end: Date? = nil,
        isValid: MeanTimeStatus? = nil,
        dragonName: Dragon.Name? = nil
        ) -> MeanTime {

        return MeanTime(start: start ?? self.start,
                        end: end ?? self.end,
                        isValid: isValid ?? self.isValid,
                        dragonName: dragonName ?? self.dragonName)
    }
}

enum MeanTimeStatus: Int, Codable {
    case shouldVaridate
    case varidated
    case injustice

    init(statusInt: Int) {
        self = MeanTimeStatus(rawValue: statusInt) ?? MeanTimeStatus.shouldVaridate
    }
}

extension Sequence where Element == MeanTime {

    var sumPlayTimeInterval: TimeInterval {
        return reduce(TimeInterval(0)) { result, meanTime in
            result + meanTime.end.timeIntervalSince(meanTime.start)
        }
    }

    func sum(onlyIn: Date) -> Double {
        return extract(by: onlyIn).sumPlayTimeInterval
    }

    func extract(by: Date) -> [MeanTime] {
        let matches = filter {
            DateUtil.display.formatter.string(from: $0.start) == DateUtil.display.formatter.string(from: by)
        }
        return matches
    }

    func getLatest(_ option: FilterOption = .all) -> MeanTime? {
        switch option {
        case .all:
            return self.max { $0.start < $1.start }
        case .valid:
            return self.filter { $0.isValid == .varidated }.max { $0.start < $1.start }
        }
    }

    func getLatestStartTime(_ option: FilterOption = .all) -> Date? {
        return getLatest(option)?.start
    }

    func getLatestEndTime(_ option: FilterOption = .all) -> Date? {
        return getLatest(option)?.end
    }

    func generateData() -> List<MeanTimeData> {
        let datas: [MeanTimeData] = compactMap { time in
            let meanTimeData = MeanTimeData()
            meanTimeData.start = time.start
            meanTimeData.end = time.end
            meanTimeData.isValid = time.isValid.rawValue
            return meanTimeData
        }
        let result = List<MeanTimeData>()
        datas.forEach { result.append($0) }
        return result
    }

    var validMeanTimes: [MeanTime] {
        return self.filter { $0.isValid == .varidated }
    }

    var shouldVaridateMeanTime: Bool {
        return self.contains(where: { $0.isValid ==  .shouldVaridate })
    }

    func continueCount(from today: Date = DateUtil.now()) -> Int {
        var startDates: [Date] = compactMap { $0.start.originDate }.sorted(by: { $0 > $1 })
        // 上から回す
        var tmpDates: [Date] = []
        var tmpDate: Date?

        for beforeDate in startDates {

            guard let afterDate = tmpDate else { // afterDateが新しいDate
                tmpDate = beforeDate
                //　今日やってないならまずない。
                tmpDates.append(beforeDate)
                continue
            }

            if afterDate.timeIntervalSince(beforeDate) > TimeInterval.oneDay {
                // 一日よりも時間が経過している場合
                break
            } else if afterDate.timeIntervalSince(beforeDate) == 0 {
                // 同じ日
                continue
            } else {
                // 次の日
                tmpDates.append(beforeDate)
                tmpDate = beforeDate
            }
        }

        if tmpDates.count > 1, tmpDates.contains(today.originDate.oneDayBefore()) {
            return tmpDates.count
        } else {
            return 0
        }
    }

    func maxContinueCount() -> Int {
        let startDates: [Date] = compactMap { $0.start.originDate }.sorted(by: { $0 > $1 })
        var maxConsectiveCount = 0
        var consectiveCount = 0
        var tmpDate: Date?
        for beforeDate in startDates {
            guard let afterDate = tmpDate else {
                tmpDate = beforeDate
                consectiveCount = 1
                continue
            }

            if afterDate.timeIntervalSince(beforeDate) > TimeInterval.oneDay {
                // 一日以上立っている場合
                if maxConsectiveCount < consectiveCount {
                    maxConsectiveCount = consectiveCount
                }
                tmpDate = beforeDate
                consectiveCount = 1
                continue
            } else if afterDate.timeIntervalSince(beforeDate) == 0 {
                // 同じ日
                continue
            } else {
                // 次の日
                tmpDate = beforeDate
                consectiveCount += 1
            }
        }

        if maxConsectiveCount < consectiveCount {
            maxConsectiveCount = consectiveCount
        }

        if maxConsectiveCount <= 1 {
            maxConsectiveCount = 0
        }

        return maxConsectiveCount
    }

}

enum FilterOption {
    case valid
    case all
}

class MeanTimeData: Object {
    @objc dynamic var start: Date?
    @objc dynamic var end: Date?
    @objc dynamic var isValid: Int = 0
}
