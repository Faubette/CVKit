//
//  ViewController.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import UIKit
import SceneKit //3D
import SpriteKit //2D
import ARKit

enum TapAction {
    case first
    case second
    case third
}

class ViewController: UIViewController {
    enum Constant {
        static let rows =  6
        static let columns = 4
        static let sizeCV = CGSize(width: 0.16, height: 0.23517)
    }
    
    //MARK: - IBOutlet
    
    @IBOutlet var sceneView: ARSCNView! // AR => ARKIT | SCN => Scenekit | VIEw

    //MARK: - Properties

    private var focusSquare = FocusSquare()
    private var matrice: Matrice = MatriceBuilder(numberColumns: Constant.columns,
                                                  numberRows: Constant.rows,
                                                  physicalSize: Constant.sizeCV).build()
    private var cvPlan: SCNNode?
    var shinningPlan: SCNNode?
    var videoPlan: SCNNode?
    var textPlan: SCNNode?
    var tapActionKind: TapAction = .first

    private var isVisibleCV = false

    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")

    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        // Set the view's delegate
        sceneView.delegate = self // Connecter au notification de la session
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
        let scene = SCNScene() // permet un espace 3D
        
        // Set the scene to the view
        sceneView.scene = scene // espace 3D donner à ARKIT
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetARWorldTrackingConfiguration()
    }
    
    func makePlan(for physicalSize: CGSize, diffuser: Diffuser, name: String) -> SCNNode {
        let widthPlan = physicalSize.width
        let heightPlan = physicalSize.height

        let plan = SCNPlane(width: widthPlan, height: heightPlan)
        plan.firstMaterial?.diffuse.contents = diffuser.content // audio | video | image

        // Création d'un node avec rotation
        let surfaceNode = SCNNode(geometry: plan)

        let pi = Float.pi

        // Faire demi tour => 180 ° => pi
        // Faire un tour complet => 180 * 2 => 360 ° => pi * 2
        // Faire un quart => 90 => 180 / 2 => pi / 2
        
        surfaceNode.transform = SCNMatrix4MakeRotation(-pi / 2, 1, 0, 0)
        surfaceNode.name = name
        return surfaceNode
    }
    
    func moveMatrice(from node: SCNNode, square: Square) {

        // Translation X
        let newOriginPointX = CGFloat(matrice.fullscreenSquare.size.width / 2)
        let newOriginPointY = CGFloat(matrice.fullscreenSquare.size.height / 2)

        let newOriginPoint: CGPoint = CGPoint(x: newOriginPointX, y: newOriginPointY)

        node.position.x = Float(newOriginPoint.x)
        node.position.y += Float(newOriginPoint.y)

        // deplacement du nouveau depart à la position du carré
        node.position.x += Float(square.position.x)
        node.position.y -= Float(square.position.y)

        // centre est le starter
        node.position.x += Float(square.size.width / 2 )
        node.position.y -= Float(square.size.height / 2 )
    }

    // MARK: - Private

    private func resetARImageTrackingConfiguration() {
        
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 1

        // On veut retrouver le CV
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImages", bundle: nil) else {
            return
        }

        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration)
    } // 2D: x y

    private func resetARWorldTrackingConfiguration() {

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.worldAlignment = .gravity
        configuration.isLightEstimationEnabled = true
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }

    private func updateFocusSquare() {
        guard !isVisibleCV else {
            return
        }
        focusSquare.unhide()

        let screenCenter = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)

        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState, // Environnement est bon
           let query = sceneView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: .any), //1: detect les plans 2: Quels sont les plans que je croise ?
           let result = sceneView.session.raycast(query).first { //Tous les ARPLANANCHOR que tu as croisés

            updateQueue.async { // background thread
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera) // ARPlanAnchor automatiquement se positionner dessus
            }
        }
    }

    private func colorPlans(for squareAIndex: SquareIndex, and squareBIndex: SquareIndex, color: UIColor) {
        guard let cvPlan = cvPlan else {
            return
        }

        let textSquare = matrice.makeContainer(squareAIndex: squareAIndex, squareBIndex: squareBIndex)
        let textPlan = makePlan(for: textSquare.size, diffuser: .color(color: color), name: "textPlan")
        cvPlan.addChildNode(textPlan)
        textPlan.pivot = SCNMatrix4MakeRotation((-Float.pi / 2), 1, 0, 0)
        textPlan.opacity = 1
        moveMatrice(from: textPlan, square: textSquare)
    }

    private func startAnimation(for node: SCNNode?) {
        guard let node = node else {
            return
        }

        runShinningAction(node: node, for:  Constant.sizeCV)
        runVideoAction(for: node, for: Constant.sizeCV)
        
    }
    // MARK: - Actions

    @objc
    private func tapAction(tapGesture: UITapGestureRecognizer) {

        switch tapActionKind {
        case .first:
            focusSquare.hide()

            let CVPlan = makePlan(for: Constant.sizeCV, diffuser: .image(imageNamed: "test"), name: "CV")
            CVPlan.position = focusSquare.position


            sceneView.scene.rootNode.addChildNode(CVPlan)

            isVisibleCV = true
            self.cvPlan = CVPlan
            tapActionKind = .second
        case .second:
            startAnimation(for: cvPlan)
            tapActionKind = .third
        case .third:
            videoPlan?.removeFromParentNode()

            colorPlans(for: 1, and: 4, color: .red)
            colorPlans(for: 21, and: 24, color: .yellow)
            colorPlans(for: 5, and: 10, color: .brown)
            colorPlans(for: 15, and: 16, color: .blue)

        default:
            break
        }
    }
}

//MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print("time: \(time)")
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) { //ARPlanAnchor

        guard let imageAnchor = anchor as? ARImageAnchor else  {
            return
        }
        
        print("j'ai trouvé l'image \(imageAnchor.referenceImage.physicalSize)") // width: 16 height: 23.577
        
        let sizeCV = imageAnchor.referenceImage.physicalSize
        
//        runShinningAction(node: node, for: sizeCV)

        let matrice = MatriceBuilder(numberColumns: 4, numberRows: 6, physicalSize: sizeCV).build()
        self.matrice = matrice
        let square = matrice.fullscreenSquare
        let containerSquarePlan = makePlan(for: square.size, diffuser: Diffuser(content: nil), name: "containerSquare")
        node.addChildNode(containerSquarePlan)
        moveMatrice(from: containerSquarePlan, square: square)

        runMatriceAnimation(node: containerSquarePlan, for: square.size)

        guard let urlPath = Bundle.main.path(forResource: "cv_laura", ofType: "mp4") else {
            return
        }
        
//        runVideoAction(for: node, for: sizeCV)
    }

}

