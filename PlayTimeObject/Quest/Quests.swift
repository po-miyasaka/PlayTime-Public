//
//  Quests.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/24.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

extension Sequence where Element == Quest {

    public var isActive: Bool {
        return self.contains { $0.isActive }
    }

    public var activeDate: Date? {
        return self.compactMap { $0.activeDate }.first
    }

    public func sort(with type: SortType) -> [Quest] {
        switch type {
        case .latest:
            return latestSortQuests()
        case .created:
            return createdSortQuests()
        case .frequency:
            return friquencySortQuests()
        }
    }

    @discardableResult
    public func latestSortQuests() -> [Quest] {
        return sorted {
            let preLhs = $0.activeDate ?? $0.meanTimes.getLatest()?.start
            let preRhs = $1.activeDate ?? $1.meanTimes.getLatest()?.start

            guard let lhs = preLhs else { return false }
            guard let rhs = preRhs else { return false }
            return lhs > rhs
        }
    }

    public var oldestFirstDate: Date? {
        return compactMap { $0.firstDate }.min(by: { $0 < $1 })
    }

    public func createdSortQuests() -> [Quest] {
        return sorted {
            $0.id > $1.id
        }
    }

    public func friquencySortQuests() -> [Quest] {
        return sorted {
            $0.meanTimes.count > $1.meanTimes.count
        }
    }

    public func allTime(withActive: Bool = true) -> TimeInterval {
        return reduce(TimeInterval(0)) { $0 + $1.playTime(withActive) }
    }

    //    func latestValidQuest() -> Quest? {
    //        return self.max {
    //            let preLhs = $0.meanTimes.getLatestStartTime(.valid)
    //            let preRhs = $1.meanTimes.getLatestStartTime(.valid)
    //
    //            guard let lhs = preLhs else { return true }
    //            guard let rhs = preRhs else { return true }
    //            return lhs > rhs
    //        }
    //    }

    public var livingQuests: [Quest] {
        return self.filter { !$0.deleted }
    }

    public var tuple: (active: [Quest], living: [Quest], deleted: [Quest]) {
        var living: [Quest] = []
        var deleted: [Quest] = []
        var active: [Quest] = []

        self.forEach { quest in
            if quest.deleted {
                deleted.append(quest)
            } else if quest.isActive {
                active.append(quest)
            } else {
                living.append(quest)
            }
        }
        return (active: active, living: living, deleted: deleted)
    }

    public func shouldVaridateQuests() -> Bool {
        return self.contains(where: { $0.shouldVaridateMeantimes })
    }

    public func attachDeleteFlag() -> [Quest] {
        let refreshed = self.map { quest -> Quest in
            guard quest.beingSelectedForDelete else { return quest }
            return quest.copy(activeDate: nil, deleted: true)
        }
        return refreshed
    }

    public func finishAllIfNeed(_ limitTime: TimeInterval? = nil, isCancelled: Bool = false) -> [Quest] {
        return self.map { quest in
            guard let _ = quest.activeDate else { return quest }
            guard !isCancelled else { return quest.copy(shouldActiveDateToNil: true) }
            return quest.record(with: limitTime)
        }
    }

    public func start(_ target: Quest) -> (refreshed: [Quest], target: Quest) {
        var targetQuest: Quest = target
        let refreshed = self.map { (quest: Quest) -> Quest in
            guard quest == target else { return quest }
            targetQuest = quest.start()
            return targetQuest
        }
        return (refreshed: refreshed, target: targetQuest)
    }

    public func validateAll(accurateDate: Date) -> [Quest] {

        return self.map { quest in

            let savingTimes = quest.meanTimes
                .filter { meanTime in
                    meanTime.end < accurateDate &&
                        meanTime.start < meanTime.end
                }
                .map { $0.copy(isValid: .varidated) }

            let faultTimes = quest.meanTimes
                .filter { meanTime in
                    meanTime.end > accurateDate ||
                        meanTime.start > meanTime.end
                }
                .map { $0.copy(isValid: .injustice) }

            if faultTimes.isEmpty == false {
                // log
            }

            let saving = quest.copy(meanTimes: savingTimes)
            return saving
        }
    }

    public func replace(targets: [Quest]) -> [Quest] {
        return map { quest in
            guard let replacing = targets.first (where: { target in target.id == quest.id }) else { return quest }
            return replacing
        }
    }

    public var allMeanTimes: [MeanTime] {
        return reduce([MeanTime]()) { $0 + $1.meanTimes }
    }

}
