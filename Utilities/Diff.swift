//
//  Diffable.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/06/09.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

public struct MovedIndexPath {
    public let before: IndexPath
    public let after: IndexPath
    
    init(_ before: IndexPath, _ after: IndexPath) {
        self.before = before
        self.after = after
    }
}

public typealias ClassifiedIndexPaths = (reloaded: [IndexPath],
    moved: [MovedIndexPath],
    deleted: [IndexPath],
    inserted: [IndexPath])

public struct Diff<T: Diffable> {
    public let old: [T]
    public let new: [T]
    
    public init(old: [T], new: [T]) {
        self.old = old
        self.new = new
    }
    
    func classifyIndice(section: Int = 0) -> ClassifiedIndexPaths {
        var table: [T.ID: (element: T, newIndex: Int)] = [:]
        
        var reloaded = [IndexPath]()
        var moved = [MovedIndexPath]()
        var deleted = [IndexPath]()
        
        new.enumerated().forEach { (i, element) in
            table[element.id] = (element, i)
        }
        
        old.enumerated().forEach {(i, element) in
            if let tuple = table[element.id] {
                // 新しいArrayにも残った。この時点ではアップデートかムーブ
                if tuple.newIndex == i {
                    // 同じインデックスなので、要素の内容が変わっていたらリロードするが、そうでなければ何もしなくてよい。
                    if tuple.element.expression == element.expression {
                        // 要素の内容が同じだったので何もしない
                    } else {
                        // 要素の内容に変更があるためリロード
                        reloaded.append(IndexPath(row: i, section: section))
                    }
                    
                } else {
                    // 違うインデックスなのでムーブ
                    moved.append(MovedIndexPath(IndexPath(row: i, section: section),
                                                IndexPath(row: tuple.newIndex, section: section)))
                }
                
                // アップデートもしくはムーブ対象のIndexPathが判明したので、Tableから削除しておく。（Tableに残ったものがインサートされたデータ）
                table.removeValue(forKey: element.id)
            } else {
                // newに含まれないエレメント。つまりデリートされた。
                deleted.append(IndexPath.init(row: i, section: section))
            }
        }
        
        let inserted = table.values.map { IndexPath.init(row: $1, section: section) }
        
        return (reloaded: reloaded,
                moved: moved,
                deleted: deleted,
                inserted: inserted)
    }
    
}

public protocol Diffable {
    associatedtype Expression: Equatable
    associatedtype ID: Hashable
    var expression: Expression { get }
    var id: ID { get }
}



extension Diff {
    
// 改善前 version1
    
//    func classifyIndice(section: Int = 0) -> ClassifiedIndexPaths {
//
//        var reloaded = [IndexPath]()
//        var moved = [MovedIndexPath]()
//
//        new.enumerated().forEach { afterElement in
//            old.enumerated().forEach { beforeElement in
//                if afterElement.element == beforeElement.element {
//
//                    if beforeElement.offset != afterElement.offset {
//                        moved.append(MovedIndexPath(IndexPath(row: beforeElement.offset, section: section),
//                                                    IndexPath(row: afterElement.offset, section: section)))
//                    } else if afterElement.element.expression != beforeElement.element.expression {
//                        // 変更がある。
//                        reloaded.append(IndexPath(row: afterElement.offset, section: section))
//                        reloaded.append(IndexPath(row: beforeElement.offset, section: section))
//                    }
//                }
//            }
//        }
//
//        let deleted = old.enumerated()
//            .compactMap {beforeElement -> Int? in
//                if !new.contains(where: { afterElement in afterElement == beforeElement.element }) {
//                    return beforeElement.offset
//                } else {
//                    return nil
//                }
//            }
//            .map { IndexPath(row: $0, section: section) }
//
//        let inserted = new.enumerated()
//            .compactMap { afterElement -> Int? in
//                if !old.contains(where: { beforeElement in beforeElement == afterElement.element }) {
//                    return afterElement.offset
//                } else {
//                    return nil
//                }
//            }
//            .map { IndexPath(row: $0, section: section) }
//
//        return (reloaded: reloaded.toSet.toArray, moved: moved, deleted: deleted, inserted: inserted)
//    }
    
    
// 改善前 version2
    
//    func classifyIndice(section: Int = 0) -> ClassifiedIndexPaths {
//
//        let oldEnumerated: [(offset: Int, element: T)] = Array(old.enumerated())
//
//        var reloaded = [IndexPath]()
//        var moved = [MovedIndexPath]()
//        var inserted = [IndexPath]()
//        var deletedItems: [(offset: Int, element: T)?] = oldEnumerated
//
//        new.enumerated().forEach { (newOffset, newElement) in
//            var isInserted = true
//
//            for (oldOffset, oldElement) in oldEnumerated {
//                if oldElement == newElement {
//                    isInserted = false
//
//                    deletedItems[oldOffset] = nil
//
//                    if oldOffset != newOffset {
//                        moved.append(MovedIndexPath(IndexPath(row: oldOffset, section: section),
//                                                    IndexPath(row: newOffset, section: section)))
//                    } else if oldElement.expression != newElement.expression {
//                        // 変更がある。
//                        reloaded.append(IndexPath(row: newOffset, section: section))
//                        reloaded.append(IndexPath(row: oldOffset, section: section))
//                    }
//                    break
//                }
//            }
//
//            if isInserted {
//                inserted.append(IndexPath(row: newOffset, section: section) )
//            }
//        }
//
//        let deletedIndexPaths = deletedItems.compactMap{ $0 }.map{ IndexPath(row: $0.offset, section: section) }
//
//        return (reloaded: reloaded.toSet.toArray,
//                moved: moved,
//                deleted: deletedIndexPaths,
//                inserted: inserted)
//    }
}
