//
//  Quest.swift
//  PlayTimeTests
//
//  Created by kazutoshi miyasaka on 2019/08/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Quick
import Nimble
import Utilities
@testable import PlayTimeObject
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
        let baseQuest = testQuest
        
        describe("クエスト") {
            
            context("ActiveDateが存在する") {
                
                DateUtil.dateGetter = { date(100) }
                let activeQuest = baseQuest.start()
                context("MeanTimeが存在する") {
                    
                    var questWithActiveDateAndMeanTime = activeQuest
                    questWithActiveDateAndMeanTime.meanTimes = meanTimesInSameDay
                    
                    let expectation = QuestExpectation(shouldVaridate: true,
                                                       activeMeanTime: 100,
                                                       playTimeWithActive: 130,
                                                       playTime: 30,
                                                       isActive: true,
                                                       latestDate: questWithActiveDateAndMeanTime.activeDate,
                                                       firstDate: questWithActiveDateAndMeanTime.meanTimes.map{ $0.start }.min(),
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(date(200), questWithActiveDateAndMeanTime, expectation)
                    
                    
//                    context ("after saved") {
//                        var expectationAfterSaved = expectation
//                        expectationAfterSaved.playTime = 20
//                        expectationAfterSaved.playTimeWithActive = 120
//                        match(date(200), questWithActiveDateAndMeanTime.generateQuestData().generateQuest()!, expectationAfterSaved)
//                    }
                    
                    
                    context ("record by timeOver") {
                        
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = questWithActiveDateAndMeanTime.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.playTime = 35
                        expectationRecordWithTime.playTimeWithActive = 35
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
                        
//                        context ("after saved") {
//                            var expectationAfterSaved = expectationRecordWithTime
//                            expectationAfterSaved.playTime = 25
//                            expectationAfterSaved.playTimeWithActive = 25
//                            match(date(300), recordedQuest.generateQuestData().generateQuest()!, expectationAfterSaved)
//                        }
                    }
                    
                    context ("record by User") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = questWithActiveDateAndMeanTime.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.playTime = 230
                        expectationRecordWithTime.playTimeWithActive = 230
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
                        
//                        context ("after saved") {
//                            var expectationAfterSaved = expectationRecordWithTime
//                            expectationAfterSaved.playTime = 220
//                            expectationAfterSaved.playTimeWithActive = 220
//                            match(date(300), recordedQuest.generateQuestData().generateQuest()!, expectationAfterSaved)
//                        }
                        
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
                    
                    match(date(200), activeQuest, expectation)
                    
//                    context ("after saved") {
//                        var expectationAfterSaved = expectation
//                        expectationAfterSaved.playTime = 0
//                        expectationAfterSaved.playTimeWithActive = 200
//                        expectationAfterSaved.activeMeanTime = 200
//                        match(date(300), activeQuest.generateQuestData().generateQuest()!, expectationAfterSaved)
//                    }
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = activeQuest.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.shouldVaridate = true
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 5
                        expectationRecordWithTime.playTimeWithActive = 5
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
                        
//                        context ("after saved") {
//                            match(date(300), recordedQuest.generateQuestData().generateQuest()!, expectationRecordWithTime)
//                        }
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = activeQuest.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.shouldVaridate = true
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 200
                        expectationRecordWithTime.playTimeWithActive = 200
                        expectationRecordWithTime.activeMeanTime = 0
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
//                        context ("after saved") {
//                            match(date(300), recordedQuest.generateQuestData().generateQuest()!, expectationRecordWithTime)
//                        }
                    }
                }
                
                
                
                
            }
            
            context("ActiveDateは存在しない"){
                context("MeanTimeが存在する") {
                    var questWithMeanTime = baseQuest
                    questWithMeanTime.meanTimes =  meanTimesInSameDay
                    
                    let expectation = QuestExpectation(shouldVaridate: true,
                                                       activeMeanTime: 0,
                                                       playTimeWithActive: 30,
                                                       playTime: 30,
                                                       isActive: false,
                                                       latestDate: questWithMeanTime.meanTimes.map{ $0.end }.max(),
                                                       firstDate: questWithMeanTime.meanTimes.map{ $0.start }.min(),
                                                       continueCount: 0,
                                                       continueCountMax: 0)
                    
                    match(date(200), questWithMeanTime, expectation)
                    
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = questWithMeanTime.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 30
                        expectationRecordWithTime.playTimeWithActive = 30
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = questWithMeanTime.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 30
                        expectationRecordWithTime.playTimeWithActive = 30
                        expectationRecordWithTime.latestDate = recordedQuest.meanTimes.map{ $0.end }.max()
                        match(date(300), recordedQuest, expectationRecordWithTime)
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
                    
                    match(date(200), baseQuest, expectation)
                    
                    
                    context ("record by timeOver") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = baseQuest.record(with: 5)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 0
                        expectationRecordWithTime.playTimeWithActive = 0
                        expectationRecordWithTime.latestDate = nil
                        match(date(300), recordedQuest, expectationRecordWithTime)
                    }
                    
                    context ("record by user") {
                        DateUtil.dateGetter = { date(300) }
                        let recordedQuest = baseQuest.record(with: nil)
                        var expectationRecordWithTime = expectation
                        expectationRecordWithTime.isActive = false
                        expectationRecordWithTime.playTime = 0
                        expectationRecordWithTime.playTimeWithActive = 0
                        expectationRecordWithTime.latestDate = nil
                        match(date(300), recordedQuest, expectationRecordWithTime)
                        
                    }
                }
            }
        }
    }
    
    func match(_ nowDate: Date,_ quest: Quest, _ expectation: QuestExpectation) {
        it("バリデート") {
            expect(quest.shouldVaridateMeantimes).to(equal(expectation.shouldVaridate))
        }
        
        it("activeMeanTime") {
            DateUtil.dateGetter = { nowDate }
            expect(quest.activeMeanTime).to(equal(expectation.activeMeanTime))
        }
        
        it("playTimeWithActiveMeanTime") {
            DateUtil.dateGetter = { nowDate }
            expect(quest.playTime(true)).to(equal(expectation.playTimeWithActive))
        }
        
        it("playtime except activeMeanTime") {
            expect(quest.playTime(false)).to(equal(expectation.playTime))
        }
        
        it("isActive") {
            expect(quest.isActive).to(equal(expectation.isActive))
        }
        
        it("latestDate") {
            expect(quest.latestDate).to(expectation.latestDate == nil ? beNil(): equal(expectation.latestDate))
        }
        
        it ("firstDate") {
            expect(quest.firstDate).to( expectation.firstDate == nil ? beNil(): equal(expectation.firstDate))
        }
        
        it("title") {
            expect(quest.title).to(equal("test"))
        }
        
        it("isNotify") {
            expect(quest.isNotify).to(equal(true))
        }
        
        it("dragonName") {
            expect(quest.dragonName).to(equal(Dragon.Name.momo))
        }
    }
}
