//
//  ChartPresenter.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/06/06Wednesday.
//  Copyright © 2018 forceUnwrap. All rights reserved.
//

import Foundation
import UIKit

protocol ChartPresenter {
    func scrolled(offsetX: Double)
    func selected(quests: [Quest])
    func layoutSetUp(viewFrame: CGRect)
}

class ChartPresenterImpl {
    init(delegate: ChartPresenterDelegate) {
        self.delegate = delegate
    }

    func layoutSetUp(viewFrame: CGRect) {
        self.viewFrame = viewFrame
    }

    weak var delegate: ChartPresenterDelegate?
    lazy var viewFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
}

extension ChartPresenterImpl: ChartPresenter {

    func selected(quests: [Quest]) {
        var model = ChartViewModel(quests: quests)
    }

    func scrolled(offsetX: Double) {

    }
}

extension ChartPresenterImpl {

}

protocol ChartPresenterDelegate: AnyObject {
    func showMetaData(model: ChartViewModel)
    func showGragh(model: ChartViewModel)
    func dissmiss()
}

struct ChartViewModel {
    lazy var titleString: String = ""
    lazy var activeCount: String = ""
    lazy var launchDateString: String = ""
    lazy var playTimeSumString: String = ""
    lazy var leadingViewDate: String = ""
    lazy var trailingViewDate: String = ""
    lazy var graphYMax: Double = 0.0
    lazy var xLines: [Double] = []
    lazy var yLines: [(start: CGPoint, end: CGPoint)] = []
    lazy var startToTommorow: [Date] = []
    let quests: [Quest]
    init(quests: [Quest]) {
        self.quests = quests
    }

    mutating func setUp() -> ChartViewModel {
        titleString = generateTitleString()
        activeCount = generateActiveCount()
        launchDateString = generateLaunchDateString()
        playTimeSumString = generatePlayTimeSumString()
        leadingViewDate = ""
        trailingViewDate = ""
        graphYMax = generateGraphYMax()
        xLines = []
        yLines = []
        startToTommorow = generateStartToTomorrow()
        return self
    }

    func  generateTitleString() -> String {
        return quests.reduce("") { $0 + " " +  $1.title }
    }

    func generateActiveCount() -> String {
        return quests.reduce(0, { $0 + $1.meanTimes.count }).toString
    }

    func generateLaunchDateString() -> String {
        return (quests.filter { $0.firstDate != nil }).min {lq, rq in
            lq.firstDate! < rq.firstDate!
        }?.firstDate?.displayText() ?? ""
    }

    func generatePlayTimeSumString() -> String {
        return quests.allTime().displayText()
    }

    mutating func generateGraphYMax() -> Double {
        guard let yMaxDate = (startToTommorow.max {lhs, rhs in
            quests.max { lq, rq in lq.meanTime(onlyAt: lhs) < rq.meanTime(onlyAt: lhs) }?.playTime() ?? 0.0 < quests.max { lq, rq in lq.meanTime(onlyAt: rhs) < rq.meanTime(onlyAt: rhs) }?.playTime() ?? 0.0
        }) else { return 0.0 }
        let yMax = quests.max { lq, rq in lq.meanTime(onlyAt: yMaxDate) < rq.meanTime(onlyAt: yMaxDate) }?.playTime() ?? 0.0 / (60 * 60)

        return yMax.toInt.otoshi(12).toDouble
    }

    func generateXLines(today: Date) -> [(start: CGPoint, end: CGPoint)] {
        return quests.map { $0.meanTime(onlyAt: today) / -(60 * 60) }
    }

    func generateYLines() -> [(start: CGPoint, end: CGPoint)] {
        return []
    }

    func generateStartToTomorrow() -> [Date] {
        return quests.first?.firstDate?.startToToday() ?? []
    }
}
