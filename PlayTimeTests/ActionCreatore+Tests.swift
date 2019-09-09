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
        let keys = ["addQuest"]
        // テスト用に適当にクエスト作成
        let mockQuest = testQuest
        //　DispatchされたActionを監視して、目的のアクションが届けば成功。
        // 目的以外のアクションが届いてしまった場合はisUnexpectActionをTrueにして返却(テストが失敗する。)
        expectActionHandler = {
            if case .addQuest(let quest) = $0 {
                XCTAssertEqual(quest, mockQuest)
                self.exp[keys[0]]?.fulfill()
                return false
            }
            return true
        }
        
        // 実際のテスト処理の前にexpは作っておく。そうしないと、テスト処理が終わった後だとfulfillの契機が失われて失敗する。
        keys.forEach { exp[$0] = XCTestExpectation(description: $0) }
        
        // アクションクリエーターを叩く。
        actionCreator.add(quest: mockQuest)
        
        // 非同期を挟むテストなので、テスト結果が出るまで処理をwaitするためにXCTestExpectationを作成
        // 指定したすべてのexpがfulfillするまでここで待機
        wait(for: Array(exp.values), timeout: 0.1)
    }
    
    func testAddStory() {
        let keys = ["addStory"]
        expectActionHandler = {
            if case .addStory(let story) = $0 {
                XCTAssertEqual(story.title, "story")
                self.exp[keys[0]]?.fulfill()
                return false
            }
            
            return true
        }
        keys.forEach { exp[$0] = XCTestExpectation(description: $0) }
        actionCreator.add(storyName: "story")
        wait(for: Array(exp.values), timeout: 0.1)
    }
    
    func testExplore() {
        let keys = ["explore", "editQuest"]
        let questMock = testQuest
        expectActionHandler = {
            
            if case Action.explore(let questID, .launch) = $0 {
                XCTAssertEqual(questID, questMock.id)
                self.exp[keys[0]]?.fulfill()
                return false
            }
            
            if case Action.editQuest(let quests) = $0 {
                XCTAssertEqual(quests.first?.id, questMock.id)
                XCTAssertTrue(quests.first?.isActive == true)
                XCTAssertEqual(quests.count, 1)
                self.exp[keys[1]]?.fulfill()
                return false
            }
            
            return true
        }
        
        keys.forEach { exp[$0] = XCTestExpectation(description: $0) }
        storiesStoreMock.allQuest = [questMock]
        actionCreator.start(quest: questMock.id, activeReason: .launch)
        wait(for: Array(exp.values), timeout: 0.1)
    }
    
    func testReturnBase() {
        let keys = ["returnBase", "editQuest"]
        let questMocks = [testQuest, testQuest, testQuest.start()]
        expectActionHandler = {
            
            if case Action.returnBase = $0 {
                self.exp[keys[0]]?.fulfill()
                return false
            }
            
            if case Action.editQuest(let quests) = $0 {
                XCTAssertTrue(questMocks.allSatisfy{ quests.contains($0) })
                XCTAssertTrue(quests.allSatisfy{ $0.isActive == false })
                XCTAssertEqual(quests.count, 3)
                self.exp[keys[1]]?.fulfill()
                return false
            }
            
            return true
        }
        
        keys.forEach { exp[$0] = XCTestExpectation(description: $0) }
        
        storiesStoreMock.allQuest = questMocks
        actionCreator.stop(with: nil)
        wait(for: Array(exp.values), timeout: 0.1)
    }
    
    
    let disposeBag = DisposeBag()
    lazy var actionCreator = ActionCreator(dispatcher: dispatcher, storiesStore: storiesStoreMock)
    var exp: [String: XCTestExpectation] = [:]
    var storiesStoreMock = StoriesStoreMock()
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
}

extension ActionCreatore_tests {
    override func setUp() {
        exp = [:]
    }
}

fileprivate let notCalledHandler = { (description: String) -> () in
    XCTAssert(false, description + "is not called")
}

fileprivate let unexpectActionHandler = { (action: Action) -> () in
    XCTAssertNil(action, "\(action) is unexpected")
}

fileprivate var expectActionHandler: ((Action) -> (Bool))?

class StoriesStoreMock: StoryStoreProtocol {
    private(set) lazy var _selected = PublishRelay<QuestUniqueID?>()
    private(set) lazy var _stories = PublishRelay<[Story]>()
    private(set) lazy var _dragons = PublishRelay<[Dragon]>()
    private(set) lazy var _allQuest = PublishRelay<[Quest]>()
    private(set) lazy var _isEditingQuests = PublishRelay<Bool>()
    private(set) lazy var _selectedForEditing = PublishRelay<Story?>()
    private(set) lazy var _activeQuest = PublishRelay<QuestUniqueID?>()
    private(set) lazy var _activeReason = PublishRelay<ActiveRoot?>()
    
    init() {}
    
    var allQuest: [Quest] = [testQuest]
    
    var stories: [Story] = [mockStory]
    
    var allQuestObservable: Observable<[Quest]> {
        return _allQuest.asObservable()
    }
    
    var storiesObservable: Observable<[Story]> {
        return _stories.asObservable()
    }
    
    var activeQuest: QuestUniqueID? {
        return nil
    }
    
    var activeReason: ActiveRoot? {
        return nil
    }
    
    var activeQuestObservable: Observable<QuestUniqueID?> {
        return _activeQuest.asObservable()
    }
    
    func questsFor(_ story: Story) -> Observable<[Quest]> {
        return _allQuest.asObservable()
    }
    
    func questsFor(_ story: Story) -> [Quest] {
        return []
    }
    
    var dragons: [Dragon] {
        return []
    }
    
    var dragonsObservable: Observable<[Dragon]> {
        return _dragons.asObservable()
    }
    
    var isEditingQuestsObservable: Observable<Bool> {
        return _isEditingQuests.asObservable()
    }
    
    var isEditingQuests: Bool {
        return true
    }
    
    var selectedForEditing: Story? {
        return nil
    }
    
    var selectedForEditingObservable: Observable<Story?> {
        return _selectedForEditing.asObservable()
    }
    
    var selectedObservable: Observable<QuestUniqueID?> {
        return _selected.asObservable()
    }
}
