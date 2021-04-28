//
//  Diffuser.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import UIKit
import SpriteKit
import AVFoundation

struct Diffuser {
    let content: Any?
}

extension Diffuser {

    static func video(urlPath: String) -> Self {

        //CHAP1  1 - prepare uh AVPlayer
        let url = URL(fileURLWithPath: urlPath)

        let player = AVPlayer(url: url)

        // 2 - Créer un SKVIDEONOde => un plan 2D avec de la video
        let videoNode = SKVideoNode(avPlayer: player)


        // 3 - Configurer SKVIDEONODE ==> photo d'un cadre
        let frameSize = CGSize(width: 1920, height: 1080) //Full HD resolution
        videoNode.size = frameSize
        videoNode.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)


        // 4 - Ajouter notre SKVIDEONODE à la scene

        let videoScene = SKScene(size: frameSize) // cadre

        // 5 - Configurer SKSCENNE
        videoScene.scaleMode = .aspectFit
        videoScene.backgroundColor = UIColor(white: 33/255, alpha: 1.0)

        // 6 - Ajouter SKVIDEONode dans SKSCENE (Ajouter la photo dans le cadre)
        videoScene.addChild(videoNode)

        // 7 - Joue la video
        videoNode.play()

        return Self(content: videoScene)
    }

    static func color(color: UIColor) -> Self {
        return Self(content: color)
    }

    static func image(imageNamed: String) -> Self {
        let imageView = UIImageView(image: UIImage(named: imageNamed))
        return Self(content: imageView)
    }

    static func text(text: String) -> Self {
        let textField = UITextField()
        textField.text = text
        textField.textColor = .red
        return Self(content: textField)
    }
}
