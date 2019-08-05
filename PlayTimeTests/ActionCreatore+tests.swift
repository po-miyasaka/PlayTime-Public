//
//  ActionCreatore+tests.swift
//  PlayTimeTests
//
//  Created by kazutoshi miyasaka on 2019/08/05.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest
import PlayTimeObject

@testable import PlayTime

class ActionCreatore_tests: XCTestCase {
    
    func testAddQuest() {

        // テスト用に適当にクエスト作成
        let mockQuest = testQuest
        
        //　DispatchされたActionを監視して、目的のアクションが届けば成功。
        // 目的以外のアクションが届いてしまった場合はisUnexpectActionをTrueにして返却(テストが失敗する。)
        expectActionHandler = {
            var isUnexpectAction = true
            if case .addQuest(let quest) = $0 {
                XCTAssertEqual(quest, mockQuest)
                isUnexpectAction = false
                self.exp?.fulfill()
            }
            return isUnexpectAction
        }
        
        // 実際のテスト処理の前にexpは作っておく。そうしないと、テスト処理が終わった後だとfulfillの契機が失われて失敗する。
        exp = XCTestExpectation(description: "addQuest")
        
        // アクションクリエーターを叩く。
        actionCreator.add(quest: mockQuest)
        
        // 非同期を挟むテストなので、テスト結果が出るまで処理をwaitするためにXCTestExpectationを作成
        // 指定したすべてのexpがfulfillするまでここで待機
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAddStory() {
        expectActionHandler = {
            var isUnexpectAction = true
            if case .addStory(let story) = $0 {
                XCTAssertEqual(story.title, "story")
                isUnexpectAction = false
                self.exp.fulfill()
            }
            
            return isUnexpectAction
        }
        exp = XCTestExpectation(description: "addStory")
        actionCreator.add(storyName: "story")
        wait(for: [exp], timeout: 0.1)
    }
    
    
    
    let disposeBag = DisposeBag()
    lazy var dispatcher = { () -> Dispatcher in
        let dispatcher = Dispatcher.default
        dispatcher.register { action in
            if expectActionHandler?(action) == true {
                unexpectActionHandler(action)
            }
            }
            .disposed(by: disposeBag)
        return dispatcher
    }()
    // 非同期を挟むテストなので、テスト結果が出るまで処理をWaitするためにXCTestExpectationを作成
    var exp: XCTestExpectation!
    lazy var actionCreator = ActionCreator(dispatcher: dispatcher)
}

fileprivate let notCalledHandler = { (description: String) -> () in
    XCTAssert(false, description + "is not called")
}

fileprivate let unexpectActionHandler = { (action: Action) -> () in
    XCTAssertNil(action, "\(action) is unexpected")
}

var expectActionHandler: ((Action) -> (Bool))?

//
//    case .addStory(_):
//        <#code#>
//    case .explore(_, _):
//        <#code#>
//    case .returnBase:
//        <#code#>
//    case .startDeletingQuests:
//        <#code#>
//    case .endDeletingQuests:
//        <#code#>
//    case .sort(_):
//        <#code#>
//    case .addStatus(_):
//        <#code#>
//    case .userSetNotification(_):
//        <#code#>
//    case .osSetNotification(_):
//        <#code#>
//    case .settingsError(_):
//        <#code#>
//    case .selected(_):
//        <#code#>
//    case .editStory(_):
//        <#code#>
//    case .deleteStory(_):
//        <#code#>
//    case .editQuest(_):
//        <#code#>
//    case .didBecomeActive:
//        <#code#>
//    case .newQuestName(_):
//        <#code#>
//    case .newQuestDragon(_):
//        <#code#>
//    case .newQuestStory(_):
//        <#code#>
//    }
//}
