//
//  Quest.swift
//  PlayTimeTests
//
//  Created by kazutoshi miyasaka on 2019/08/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Quick
import Nimble

@testable import PlayTime

class QuestTests: QuickSpec { // itの中でitは使えない
    
    
    struct QuestExpectation {
        var shouldVaridate: Bool
        var activeMeanTime: TimeInterval
        var playTimeWithActive: TimeInterval
        var playTime: TimeInterval
        var isActive: Bool
        var latestDate: Date?
        var firstDate: Date?
        var continueCount: Int
        var continueCountMax: Int
    }
    
    override func spec() {
        let baseQuest = Quest.new(title: "test", isNotify: true, dragonName: .momo, story: mockStory)
        
        let match: ((Date, Quest, QuestExpectation) -> ()) = { nowDate, quest, expectation in
            it("バリデート") {
                expect(expectation.shouldVaridate).to(equal(quest.shouldVaridateMeantimes))
            }
            
            it("playtime with activeMeanTime") {
                DateUtil.dateGetter = { nowDate }
                expect(expectation.activeMeanTime).to(equal(quest.activeMeanTime))
                expect(expectation.playTimeWithActive).to(equal(quest.playTime(true)))
            }
            
            it("playtime except activeMeanTime") {
                expect(expectation.playTime).to(equal(quest.playTime(false)))
            }
            
            it("isActive") {
                expect(expectation.isActive).to(equal(quest.isActive))
            }
            
            it("latestDate is activeDate") {
                
                expect(expectation.latestDate).to(expectation.latestDate == nil ? beNil(): equal(quest.latestDate))
            }
            
            it ("firstDate is activeDate") {
                expect(expectation.firstDate).to( expectation.firstDate == nil ? beNil(): equal(quest.firstDate))
            }
        }
        
        
        describe("クエスト") {
            context("ActiveDateが存在する") {
                
                DateUtil.dateGetter = { dateFrom2000(until: 100) }
                let activeQuest = baseQuest.start()
                context("MeanTimeが存在する") {
                    
                    var questWithActiveDateAndMeanTime = activeQuest
                    questWithActiveDateAndMeanTime.meanTimes =  [testMeanTimesVaridated(),
                                                                 testMeanTimesInvalidated(),
                                                                 testMeanTimesShouldVaridate()]
                    
                    let expectation = QuestExpectation(shouldVaridate: true,
                                                       activeMeanTime: 100,
                                                       playTimeWithActive: 130,
                                                       playTime: 30,
                                                       isActive: true,
                                                       latestDate: questWithActiveDateAndMeanTime.activeDate,
                                                       firstDate: questWithActiveDateAndMeanTime.meanTimes.map{ $0.start }.min(),
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(dateFrom2000(until: 200), questWithActiveDateAndMeanTime, expectation)
                    
                    context ("record by timeOver") {
                        
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = questWithActiveDateAndMeanTime.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.playTime = 35
                        expectationRecordWithTime.playTimeWithActive = 35
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by User") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = questWithActiveDateAndMeanTime.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.playTime = 230
                        expectationRecordWithTime.playTimeWithActive = 230
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                        
                    }
                }
                
                context("MeanTimeが存在しない") {
                    
                    let expectation = QuestExpectation(shouldVaridate: false,
                                                       activeMeanTime: 100,
                                                       playTimeWithActive: 100,
                                                       playTime: 0,
                                                       isActive: true,
                                                       latestDate: activeQuest.activeDate,
                                                       firstDate: activeQuest.activeDate,
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(dateFrom2000(until: 200), activeQuest, expectation)
                    
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = activeQuest.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.shouldVaridate = true
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 5
                        expectationRecordWithTime.playTimeWithActive = 5
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = activeQuest.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.shouldVaridate = true
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 200
                        expectationRecordWithTime.playTimeWithActive = 200
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                }
                
                
                
                
            }
            
            context("ActiveDateは存在しない"){
                
                context("MeanTimeが存在する") {
                    var questWithMeanTime = baseQuest
                    questWithMeanTime.meanTimes =  meanTimesAllType
                    
                    let expectation = QuestExpectation(shouldVaridate: true,
                                                       activeMeanTime: 0,
                                                       playTimeWithActive: 30,
                                                       playTime: 30,
                                                       isActive: false,
                                                       latestDate: questWithMeanTime.meanTimes.map{ $0.end }.max(),
                                                       firstDate: questWithMeanTime.meanTimes.map{ $0.start }.min(),
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(dateFrom2000(until: 200), questWithMeanTime, expectation)
                    
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = questWithMeanTime.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 30
                        expectationRecordWithTime.playTimeWithActive = 30
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = questWithMeanTime.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 30
                        expectationRecordWithTime.playTimeWithActive = 30
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    
                }
                
                context("MeanTimeが存在しない") {
                    let expectation = QuestExpectation(shouldVaridate: false,
                                                       activeMeanTime: 0,
                                                       playTimeWithActive: 0,
                                                       playTime: 0,
                                                       isActive: false,
                                                       latestDate: nil,
                                                       firstDate: nil,
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(dateFrom2000(until: 200), baseQuest, expectation)
                    
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = baseQuest.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 0
                        expectationRecordWithTime.playTimeWithActive = 0
                        expectationRecordWithTime.latestDate = nil
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { dateFrom2000(until: 300) }
                        let recordedQuest = baseQuest.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 0
                        expectationRecordWithTime.playTimeWithActive = 0
                        expectationRecordWithTime.latestDate = nil
                        match(dateFrom2000(until: 300), recordedQuest, expectationRecordWithTime)
                        
                    }
                }
            }
        }
    }
}

var meanTimesAllVaridated: [MeanTime] {
    return [testMeanTimesVaridated(), testMeanTimesVaridated(), testMeanTimesVaridated()]
}

var meanTimesContainsInVaridated: [MeanTime] {
    return [testMeanTimesVaridated(), testMeanTimesVaridated(), testMeanTimesInvalidated()]
}

var meanTimesAllInVaridated: [MeanTime] {
    return [testMeanTimesInvalidated(), testMeanTimesInvalidated(), testMeanTimesInvalidated()]
}

var meanTimesContainsShouldValidate: [MeanTime] {
    return [testMeanTimesVaridated(), testMeanTimesVaridated(), testMeanTimesShouldVaridate()]
}

var meanTimesContainsAllShouldValidate: [MeanTime] {
    return [testMeanTimesShouldVaridate(), testMeanTimesShouldVaridate(), testMeanTimesShouldVaridate()]
}

var meanTimesAllType: [MeanTime] {
    return [testMeanTimesVaridated(), testMeanTimesShouldVaridate(), testMeanTimesInvalidated()]
}

func testMeanTimesVaridated(dragonName: Dragon.Name = .leo) -> MeanTime {
    return MeanTime(start: dateFrom2000(until: 10),
                    end: dateFrom2000(until: 20),
                    isValid: .varidated,
                    dragonName: dragonName)
}

func testMeanTimesInvalidated(dragonName: Dragon.Name = .travan) -> MeanTime {
    return MeanTime(start: dateFrom2000(until: 30),
                    end: dateFrom2000(until: 40),
                    isValid: .injustice,
                    dragonName: dragonName)
    
}

func testMeanTimesShouldVaridate(dragonName: Dragon.Name = .momo) -> MeanTime {
    return MeanTime(start: dateFrom2000(until: 50),
                    end: dateFrom2000(until: 60),
                    isValid: .shouldVaridate,
                    dragonName: dragonName)
}

var mockStory: Story {
    return Story.new(title: "テストストーリー")
}

func dateFrom2000(until: TimeInterval) -> Date {
    return Date(timeIntervalSinceReferenceDate: until)
}
