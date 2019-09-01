//
//  Diff+UI.swift
//  Utilities
//
//  Created by kazutoshi miyasaka on 2019/09/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

extension Diff {
    public func update(_ tableView: UITableView, section: Int = 0) {
        let tuple = classifyIndice(section: section)
        tableView.beginUpdates()
        if tuple.reloaded.isNotEmpty {
            tableView.reloadRows(at: tuple.reloaded, with: .fade)
        }
        if tuple.deleted.isNotEmpty {
            tableView.deleteRows(at: tuple.deleted, with: .fade)
        }
        if tuple.inserted.isNotEmpty {
            tableView.insertRows(at: tuple.inserted, with: .fade)
        }
        tableView.endUpdates()
    }
    
    
    public func update(_ collectionView: UICollectionView, section: Int = 0) {
        collectionView.performBatchUpdates({
            let tuple = classifyIndice(section: section)
            
            tuple.moved.forEach {
                collectionView.moveItem(at: $0.before, to: $0.after)
            }
            
            if tuple.reloaded.isNotEmpty {
                collectionView.reloadItems(at: tuple.reloaded)
            }
            
            if tuple.deleted.isNotEmpty {
                collectionView.deleteItems(at: tuple.deleted)
            }
            
            if tuple.inserted.isNotEmpty {
                collectionView.insertItems(at: tuple.inserted)
            }
        })
    }
}
