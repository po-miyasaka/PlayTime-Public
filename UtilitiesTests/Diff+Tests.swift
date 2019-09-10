//
//  UtilitiesTests.swift
//  UtilitiesTests
//
//  Created by kazutoshi miyasaka on 2019/08/03.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import XCTest
@testable import Utilities

infix operator =~=

class DiffTests: XCTestCase {
    
    // 1 = 空の場合
    func test_空To空() {
        target(old: empty,
               new: empty)
            
            =~= expected()
    }
    
    // 4 = 4 C 1
    func test_インサートのみ() {
        target(old: empty,
               new: v1_2_3_4_5_6)
            
            =~= expected(inserted: [0, 1, 2, 3, 4, 5])
        
        
        target(old: v2_4_6,
               new: v2_4_6_8_10_12)
            
            =~= expected(inserted: [3, 4, 5])
        
    }
    
    func test_ムーブのみ() {
        target(old: v2_4_6_8_10_12,
               new: v2_4_6_8_10_12.reversed())
            
            =~= expected(moved: [(0, 5),
                                 (1, 4),
                                 (2, 3),
                                 (3, 2),
                                 (4, 1),
                                 (5, 0)])
    }
    
    func test_リロードのみ() {
        target(old: v1_2_3,
               new: v1_2_3)
            
            =~= expected(reloaded: [0, 2])
        
    }
    
    func test_デリートのみ() {
        target(old: v2_4_6_8_10_12,
               new: v2_4_6)
            
            =~= expected(deleted: [3, 4, 5])
        
        
        target(old: v1_3_5_7_9_11,
               new: empty)
            
            =~= expected(deleted: [0, 1, 2, 3, 4, 5])
        
    }
    
    // 6 = 4 C 2
    func test_インサート＆ムーブ() {
        target(old: v8_10_12,
               new: v2_4_6_8_10_12)
            
            =~= expected(inserted: [0, 1, 2],
                         moved: [(0, 3),
                                 (1, 4),
                                 (2, 5)])
        
    }
    
    func test_インサート＆リロード() {
        target(old: v1_3_5,
               new: v1_3_5_7_9_11)
            
            =~= expected(inserted: [3, 4, 5],
                         reloaded: [0, 1, 2])
        
    }
    
    func test_インサート＆デリート() {
        target(old: v1_3_5,
               new: v7_9_11)
            
            =~= expected(inserted: [0, 1, 2],
                         deleted: [0, 1, 2])
    }
    
    func test_リロード＆デリート() {
        target(old: v1_3_5_7_9_11,
               new: v1_3_5)
            
            =~= expected(reloaded: [0, 1, 2],
                         deleted: [3, 4, 5])
    }
    
    func test_リロード＆ムーブ() {
        target(old: v7_9_11,
               new: v7_9_11.reversed())
            
            =~= expected(reloaded: [1],
                         moved: [(0, 2),
                                 (2, 0)])
        
    }
    
    func test_デリート＆ムーブ() {
        target(old: v2_4_6 + v8_10_12,
               new: v8_10_12)
            
            =~= expected(moved: [(3, 0),
                                 (4, 1),
                                 (5, 2)],
                         deleted: [0, 1, 2])
        
    }
    
    // 4 = 4 C 3
    func test_インサート＆デリート＆ムーブ() {
        target(old: v1_2_3_4_5_6,
               new: v2_4_6_8_10_12)
            
            =~= expected(inserted: [3, 4, 5],
                         moved: [(1, 0),
                                 (3, 1),
                                 (5, 2)],
                         deleted: [0, 2, 4])
        
    }
    
    func test_インサート＆デリート＆リロード() {
        target(old: v1_3_5 + v7_9_11,
               new: v1_3_5 + v8_10_12)
            
            =~= expected(inserted: [3, 4, 5],
                         reloaded:  [0, 1, 2],
                         deleted: [3, 4, 5])
        
    }
    
    func test_インサート＆リロード＆ムーブ() {
        target(old: v1_3_5 + v7_9_11.reversed(),
               new: v1_3_5 + v7_9_11 + v8_10_12)
            
            =~= expected(inserted: [6, 7, 8],
                         reloaded:  [0, 1, 2, 4],
                         moved: [(3, 5),
                                 (5, 3)])
        
    }
    
    func test_デリート＆リロード＆ムーブ() {
        target(old: v1_3_5 + v8_10_12,
               new: v1_3_5.reversed())
            
            =~= expected(reloaded:  [1],
                         moved: [(0, 2),
                                 (2, 0)],
                         deleted:[3, 4, 5])
    }
    
    // 1 = 4 C 4
    func test_インサート＆デリート＆リロード＆ムーブ() {
        target(old: v1_3_5 + v8_10_12,
               new: v1_3_5.reversed() + v7_9_11)
            
            =~= expected(inserted: [3, 4, 5],
                         reloaded:  [1],
                         moved: [(0, 2),
                                 (2, 0)],
                         deleted:[3, 4, 5])
    }
    
    // その他
    func test_インサート＆デリート＆リロード＆ムーブ_セクションを変える() {
        target(old: v1_3_5 + v8_10_12,
               new: v1_3_5.reversed() + v7_9_11, section: 1)
            
            =~= expected(inserted: [3, 4, 5],
                         reloaded:  [1],
                         moved: [(0, 2),
                                 (2, 0)],
                         deleted:[3, 4, 5], section: 1)
    }
    
    func test_パフォーマンス() {
        
        let old = (0...5000).map{ $0 }.toSet.toArray.mock
        let new = (0...6000).filter{ $0 % 3 == 0 }.reversed().toSet.toArray.mock
        var result: ClassifiedIndexPaths!
        
        measure {
            result = target(old: old, new: new)
        }
        
        print("inserted")
        print(result.inserted.count)
        
        print("deleted")
        print(result.deleted.count)
        
        print("reloaded")
        print(result.reloaded.count)
        
        print("moved")
        print(result.moved.count)
        
        print("all")
        print(result.inserted.count +
            result.deleted.count +
            result.reloaded.count +
            result.moved.count)
    }
}

// - MARK: 以下Diff + Tests用のUtilities

extension DiffTests {
    func target(old : [DiffableMock], new: [DiffableMock], section: Int = 0) -> ClassifiedIndexPaths {
        let diff = Diff(old: old, new: new)
        return diff.classifyIndice(section: section)
    }
    
    
    // 奇数はリロード対象
    var empty: [DiffableMock] { return [] }
    var v2_4_6: [DiffableMock] { return  [2, 4, 6].mock }
    var v1_3_5: [DiffableMock] { return  [1, 3, 5].mock }
    
    var v8_10_12: [DiffableMock] { return [8, 10, 12].mock }
    var v7_9_11: [DiffableMock] { return  [7, 9, 11].mock }
    
    var v2_4_6_8_10_12: [DiffableMock] { return [2, 4, 6, 8, 10, 12].mock }
    var v1_3_5_7_9_11: [DiffableMock] { return [1, 3, 5, 7, 9, 11].mock }
    
    var v1_2_3: [DiffableMock] { return [1, 2, 3].mock }
    var v4_5_6: [DiffableMock] { return [4, 5, 6].mock }
    var v1_2_3_4_5_6: [DiffableMock] { return  [1, 2, 3, 4, 5, 6].mock }
}

extension Array where Element == Int {
    var mock: [DiffableMock] {
        return map{
            if $0 % 2 == 0 {
                return DiffableMock(id: $0) // 偶数はExpを変えない。つまり、リロードはしない。
            } else {
                return DiffableMock(id: $0, exp: 1000000000.random.toString) // 奇数はEXPを変えるのでリロード対象
            }
        }
    }
}

struct DiffExpectation {
    var inserted: Set<IndexPath>
    var reloaded: Set<IndexPath>
    var moved: Set<MovedIndexPath>
    var deleted: Set<IndexPath>
    
    init(inserted: Set<IndexPath> = [].toSet,
         reloaded: Set<IndexPath> = [].toSet,
         moved: Set<MovedIndexPath> = [].toSet,
         deleted: Set<IndexPath> = [].toSet,
         section: Int = 0) {
        self.inserted = inserted
        self.reloaded = reloaded
        self.moved = moved
        self.deleted = deleted
    }
    
    static func =~=(lhs: ClassifiedIndexPaths,
                    rhs: DiffExpectation) {
        XCTAssertEqual(rhs.inserted, lhs.inserted.toSet, "inserted")
        XCTAssertEqual(rhs.reloaded, lhs.reloaded.toSet, "reloaded")
        XCTAssertEqual(rhs.moved, lhs.moved.toSet, "moved")
        XCTAssertEqual(rhs.deleted, lhs.deleted.toSet, "deleted")
    }
}

extension MovedIndexPath: Hashable {
    public static func == (lhs: MovedIndexPath, rhs: MovedIndexPath) -> Bool {
        return lhs.before == rhs.before && lhs.after == rhs.after
    }
    
    public func hash(into hasher: inout Hasher) { }
}

class DiffableMock: Diffable {
    public typealias Expression = String
    
    static func == (lhs: DiffableMock, rhs: DiffableMock) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var expression: String {
        return exp ?? id.toString
    }
    
    let exp: String?
    let id: Int
    
    init(id: Int, exp: String? = nil) {
        self.id = id
        self.exp = exp
    }
}

fileprivate func expected(inserted: [Int] = [],
                          reloaded: [Int] = [],
                          moved: [(Int, Int)] = [],
                          deleted: [Int] = [],
                          section: Int = 0) -> DiffExpectation {
    let inserted = inserted.map{ IndexPath.init(row: $0, section: section) }.toSet
    let reloaded = reloaded.map{ IndexPath.init(row: $0, section: section) }.toSet
    
    let moved: Set<MovedIndexPath> = moved.map {
        let before = IndexPath.init(row: $0.0, section: section)
        let after = IndexPath.init(row: $0.1, section: section)
        return MovedIndexPath.init(before, after)
        }.toSet
    
    let deleted = deleted.map{ IndexPath.init(row: $0, section: section) }.toSet
    
    return DiffExpectation.init(inserted: inserted, reloaded: reloaded, moved: moved, deleted: deleted, section: section)
}
