//
//  ViewController+SCNAction.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import SceneKit

//MARK: - SCNACtion
extension ViewController {
    
    func runShinningAction(node: SCNNode, for size: CGSize) {
    
        let shiningPlan = makePlan(for: size,
                                   diffuser: .color(color: .white),
                                   name: "shiningPlan")

        node.addChildNode(shiningPlan)
        shiningPlan.pivot = SCNMatrix4MakeRotation((-Float.pi / 2), 1, 0, 0)

        let shiningAction = SCNAction.sequence([
            .move(to: SCNVector3(x: 0, y: 0.02, z: 0), duration: 0.5),
            .wait(duration: 0.10),
            .fadeOpacity(to: 0.85, duration: 0.20),
            .fadeOpacity(to: 0.15, duration: 0.20),
            .fadeOpacity(to: 0.85, duration: 0.20),
            .fadeOpacity(to: 0.85, duration: 0.20),
            .fadeOpacity(to: 0.15, duration: 0.20),
            .fadeOpacity(to: 0.85, duration: 0.20),
            .move(to: SCNVector3(x: Float(size.width), y: 0, z: 0), duration: 0.5),
            .fadeOut(duration: 0.4)
        ])

        shiningPlan.runAction(shiningAction)
        self.shinningPlan = shiningPlan
    }

    func runMatriceAnimation(node: SCNNode, for size: CGSize) {

        let matrice = MatriceBuilder.init(numberColumns: 4, numberRows: 6, physicalSize: size).build()
        let squares = matrice.squares
        let squaresPlan = squares.map { square -> SCNNode in
            let squarePlan = makePlan(for: square.size, diffuser: .color(color: .white), name: "")
            squarePlan.opacity = 0
            let randomStartAnimation = CGFloat.random(in: 0...2)
            print("randomStartAnimation \(randomStartAnimation)")

            let squareAction = SCNAction.sequence([.wait(duration: 2.20),
                                                   .wait(duration: TimeInterval(randomStartAnimation)),
                                                   .fadeIn(duration: 1),
                                                   .fadeOut(duration: 1)]
            )

            squarePlan.runAction(squareAction)
            return squarePlan
        }

        _ = squaresPlan.compactMap(node.addChildNode(_:))
    }
    
    func runVideoAction(for node: SCNNode, for size: CGSize) {
        guard let urlPath = Bundle.main.path(forResource: "cv_laura", ofType: "mp4") else {
            return
        }
        let videoPlan = makePlan(for: size, diffuser: .video(urlPath: urlPath), name: "videoPlan")
        node.addChildNode(videoPlan)
        videoPlan.opacity = 0
        videoPlan.pivot = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        videoPlan.position = SCNVector3(x: Float(size.width), y: 0, z: 0)
        
        let videoAction = SCNAction.sequence([
            .wait(duration: 2.20),
            .fadeIn(duration: 0.4)
        ])

        videoPlan.runAction(videoAction)
        self.videoPlan = videoPlan
    }
}
