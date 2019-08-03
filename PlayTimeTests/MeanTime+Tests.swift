//
//  MeanTime.swift
//  PlayTimeTests
//
//  Created by kazutoshi miyasaka on 2019/08/02.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Quick
import Nimble

@testable import PlayTime

class MeanTimesTests: QuickSpec {

    
    struct MeanTimesExpectation {
        var sum: TimeInterval
        var getLatestStartDate: Date?
        var getLatestEndDate: Date?
        var getFirstStartDate: Date?
        var getFirstEndDate: Date?
        var validMeanTimeInterval: TimeInterval?
        var shouldVaridate: Bool?
        var continueCount: Int
        var maxContinueCount: Int
    }
    
    override func spec() {
        describe("MeanTimes") {
            context("同じ日付のMeanTimes") {
                let meanTimes = meanTimesInSameDay
                
                let expectation = MeanTimesExpectation(sum: 30,
                                                       getLatestStartDate: meanTimes.map{ $0.start }.max(),
                                                       getLatestEndDate: meanTimes.map{ $0.end }.max(),
                                                       getFirstStartDate: meanTimes.map{ $0.start }.min(),
                                                       getFirstEndDate: meanTimes.map{ $0.end }.min(),
                                                       validMeanTimeInterval: meanTimes.filter{ $0.isValid == .varidated }.sum,
                                                       shouldVaridate: meanTimes.contains{ $0.isValid == .shouldVaridate },
                                                       continueCount: 0,
                                                       maxContinueCount: 0)
                
                match(nowDate: DateUtil.now(), target: meanTimes, expectation: expectation)
            }
            context("連続した日付のMeanTimes") {
                let meanTimes = meanTimesConsectiveDays
                
                let expectation = MeanTimesExpectation(sum: 30,
                                                       getLatestStartDate: meanTimes.map{ $0.start }.max(),
                                                       getLatestEndDate: meanTimes.map{ $0.end }.max(),
                                                       getFirstStartDate: meanTimes.map{ $0.start }.min(),
                                                       getFirstEndDate: meanTimes.map{ $0.end }.min(),
                                                       validMeanTimeInterval: meanTimes.filter{ $0.isValid == .varidated }.sum,
                                                       shouldVaridate: meanTimes.contains{ $0.isValid == .shouldVaridate },
                                                       continueCount: 0,
                                                       maxContinueCount: 3)
                
                match(nowDate: DateUtil.now(), target: meanTimes, expectation: expectation)
            }
            context("最高連続記録が過去にあるMeanTimes") {
                let meanTimes = meanTimesConsectiveDaysPast
                let expectation = MeanTimesExpectation(sum: 90,
                                                       getLatestStartDate: meanTimes.map{ $0.start }.max(),
                                                       getLatestEndDate: meanTimes.map{ $0.end }.max(),
                                                       getFirstStartDate: meanTimes.map{ $0.start }.min(),
                                                       getFirstEndDate: meanTimes.map{ $0.end }.min(),
                                                       validMeanTimeInterval: meanTimes.filter{ $0.isValid == .varidated }.sum,
                                                       shouldVaridate: meanTimes.contains{ $0.isValid == .shouldVaridate },
                                                       continueCount: 3,
                                                       maxContinueCount: 6)
                context("現在時刻が最後に実行した日") {
                    match(nowDate: date(20).addingTimeInterval(.oneDay * 9),target: meanTimes,
                           expectation: expectation)
                }
                
                context("現在時刻が最後に実行した次の日") {
                    match(nowDate: date(20).addingTimeInterval(.oneDay * 10),
                          target: meanTimes,
                          expectation: expectation)
                }
                
                context("現在時刻が最後に実行した次の次の日") {
                    var expectationForContinueCount = expectation
                    expectationForContinueCount.continueCount = 0
                    match(nowDate: date(20).addingTimeInterval(.oneDay * 11),
                        target: meanTimes,
                          expectation: expectationForContinueCount)
                }
                
                
            }
        }
    }
    
    func match(nowDate: Date, target: [MeanTime], expectation: MeanTimesExpectation ) {
        it("sum") {
            expect(target.sum).to(equal(expectation.sum))
        }
        
        it("getlatestStartDate") {
            expect(target.getLatest()?.end).to(equal(expectation.getLatestEndDate))
        }
        
        it("getLatestEndDate") {
            expect(target.getLatest()?.start).to(equal(expectation.getLatestStartDate))
        }
        
        it("getFirstStartDate") {
            expect(target.getFirst()?.start).to(equal(expectation.getFirstStartDate))
        }
        
        it("getFirstEndDate") {
            expect(target.getFirst()?.end).to(equal(expectation.getFirstEndDate))
        }
        
        it("validMeanTimeInterval") {
            expect(target.validMeanTimes.sum).to(equal(expectation.validMeanTimeInterval))
        }
        
        it("shouldVaridateMeanTimeInterval") {
            expect(target.shouldVaridateMeanTime).to(equal(expectation.shouldVaridate))
        }
        
        it("contenueCount") {
            expect(target.continueCount(from: nowDate)).to(equal(expectation.continueCount))
        }
        
        it("contenueCountMax") {
            expect(target.maxContinueCount()).to(equal(expectation.maxContinueCount))
        }
    }
}
