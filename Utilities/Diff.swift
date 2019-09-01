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
        
        let oldEnumerated: [(offset: Int, element: T)] = Array(old.enumerated())
        
        var reloaded = [IndexPath]()
        var moved = [MovedIndexPath]()
        var inserted = [IndexPath]()
        var deletedItems: [(offset: Int, element: T)?] = oldEnumerated
        
        new.enumerated().forEach { (newOffset, newElement) in
            var isInserted = true
            
            for (oldOffset, oldElement) in oldEnumerated {
                if oldElement == newElement {
                    isInserted = false
                    
                    deletedItems[oldOffset] = nil
                    
                    if oldOffset != newOffset {
                        moved.append(MovedIndexPath(IndexPath(row: oldOffset, section: section),
                                                    IndexPath(row: newOffset, section: section)))
                    } else if oldElement.expression != newElement.expression {
                        // 変更がある。
                        reloaded.append(IndexPath(row: newOffset, section: section))
                        reloaded.append(IndexPath(row: oldOffset, section: section))
                    }
                    break
                }
            }
            
            if isInserted {
                inserted.append(IndexPath(row: newOffset, section: section) )
            }
        }
        
        let deletedIndexPaths = deletedItems.compactMap{ $0 }.map{ IndexPath(row: $0.offset, section: section) }
        
        return (reloaded: reloaded.toSet.toArray,
                moved: moved,
                deleted: deletedIndexPaths,
                inserted: inserted)
    }
    
}

public protocol Diffable: Equatable {
    associatedtype Expression: Equatable
    var expression: Expression { get }
}
