//
//  Dragon.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/03/09Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import SpriteKit
import Utilities


public class Dragon {

    public var name: Name
    public var process: Process
    public var images: DragonImages
    public var necessaryExperience: Int? //　次の進化までに必要な時間
    public var playTimeHour: Int // 今までためた経験値

    public class var profileHeight: CGFloat { return 200 }
    public class var profileWidth: CGFloat { return 180 }

    public init?(name: Name, process: Process, playTimeHour: Int) {
        self.playTimeHour = playTimeHour

        if let needed = process.necessaryExperienceForEvolve {
            self.necessaryExperience = max( needed - playTimeHour, 0)
        }

        self.name = name
        self.process = process
        guard let images = DragonImages(name: name, process: process) else { return nil }
        self.images = images
    }

    public static func create(meanTimes: [MeanTime]) -> [Dragon] {
        let validTimes = meanTimes.validMeanTimes

        var grouped = validTimes.groupBy { $0.dragonName }
        Dragon.Name.allCases.forEach {
            grouped[$0] = grouped[$0] ?? []
        }

        let dragons: [Dragon] = grouped.compactMap { name, meanTimes in
            let allTime: TimeInterval = meanTimes.sum
            let process = Dragon.Process(name: name, hour: allTime.hour)
            return Dragon(name: name, process: process, playTimeHour: allTime.hour)
        }

        return dragons
    }

    public func move(duration: TimeInterval = 1, distance: CGFloat = 20, fieldFrame: CGRect) {

        switch process {
        case .egg:
            return
        }
        guard let cache = nodeCache else { return }
        let x = cache.position.x
        let y = cache.position.y
        let point: CGPoint

        var actionGroup: [SKAction] = []

        switch MoveType(10.random) {
        case .right:
            guard (x + distance) < fieldFrame.width else { return }
            point = CGPoint(x: x + distance, y: y)
            if cache.xScale < 0 {
                actionGroup.append( SKAction.scaleX(by: -1, y: 1, duration: 0))
            }

        case .left:
            guard (x - distance) > 0 else { return }
            point = CGPoint(x: x - distance, y: y)
            if cache.xScale > 0 {
                actionGroup.append( SKAction.scaleX(by: -1, y: 1, duration: 0))
            }

        case .down:
            guard (y - distance) > 150 else { return }
            point = CGPoint(x: x, y: y - distance)

        case .up:
            guard (y + distance) < fieldFrame.height - 30 else { return }
            point = CGPoint(x: x, y: y + distance)

        case .none:
            point = cache.position
        }

        actionGroup.append(SKAction.move(to: point, duration: duration))
        nodeCache?.run(SKAction.group(actionGroup))
    }

    public enum MoveType: Int {
        case right = 0
        case down
        case left
        case up
        case none

        public init(_ value: Int) {
            self = MoveType(rawValue: value) ?? MoveType.none
        }
    }

    public var walk: SKAction {
        return SKAction.repeatForever(SKAction.animate(with: images.images, timePerFrame: 0.5))
    }

    public var nodeCache: SKSpriteNode?
    public func createNode() -> SKSpriteNode {
        let node = SKSpriteNode(texture: images.images[0])
        node.name = self.nameString
        node.run(walk)
        node.run(SKAction.scale(by: 1.0, duration: 0))
        node.run(SKAction.scale(by: 2.0, duration: 0))
        node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        nodeCache = node
        return node
    }

    public func presentOn(parent: SKView) {
        if parent.width < Dragon.profileWidth || parent.height < Dragon.profileHeight {
            assertionFailure("The view's frame is too small")
        }
        parent.scene?.removeAllChildren()
        parent.scene?.removeAllActions()

        parent.allowsTransparency = true
        parent.backgroundColor = .clear

        let node = createNode()

        let scene = SKScene(size: CGSize(width: Dragon.profileWidth, height: Dragon.profileHeight))
        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        scene.addChild(node)
        node.position = CGPoint(x: Dragon.profileWidth / 2, y: 0)
        node.zPosition = 10

        parent.presentScene(scene)
    }

    public var nameString: String {
        switch (name, process) {
        case (.nii, .egg):
            return "nii0".localized
        case (.momo, .egg):
            return "momo0".localized
        case (.travan, .egg):
            return "sea0".localized
        case (.leo, .egg):
            return "leo0".localized

        }
    }

    public var expression: String {
        switch (name, process) {
        case (.nii, .egg):
            return "nii0e".localized
        case (.momo, .egg):
            return "momo0e".localized
        case (.travan, .egg):
            return "tra0e".localized
        case (.leo, .egg):
            return "leo0e".localized
        }
    }

}

public class DragonImages {
    public var name: Dragon.Name
    public var process: Dragon.Process
    public var images: [SKTexture] {
        return (0...1).compactMap { i in
            let name = "d_\(self.name.rawValue)_\(self.process.rawValue)_\(i)"
            if let _ = UIImage(named: name) {
                return SKTexture(imageNamed: name)
            }
            return nil
        }
    }

    public var illust: UIImage? {
        return UIImage(named: "di_\(self.name.rawValue)_\(self.process.rawValue)")
    }

    public init?(name: Dragon.Name, process: Dragon.Process) {
        self.name = name
        self.process = process

        let name = "d_\(self.name.rawValue)_\(self.process.rawValue)_0"
        if let _ = UIImage(named: name) {
        } else {
            return nil
        }
    }
}

public extension Dragon {
    public enum Name: Int, Codable, CaseIterable {
        case nii = 0
        case travan
        case leo
        case momo
    }

}

extension Dragon {

    public enum Process: Int, CaseIterable {
        case egg = 0

        public var necessaryExperienceForEvolve: Int? {
            switch self {
            case .egg:
                return 20
            }
        }

        public var necessaryExperienceForShowingLibrary: Int {
            switch self {
            case .egg:
                return 0
            }
        }

        public init(name: Dragon.Name, hour: Int) {

            var result: Process
            switch hour {
            case (Int.min...19):
                result = .egg
            default:
                result = .egg
            }

            self = result
        }

        public init(lv: Int) {
            self = Dragon.Process(rawValue: min(lv, 5))!
        }

        public var scale: SKAction {
            switch self {
            case .egg:
                return SKAction.scale(by: 2, duration: 0)
            default:
                return SKAction.scale(by: 1.5, duration: 0)
            }
        }
    }
}
