//
//  SCNNode+Geometry.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import SceneKit

extension SCNNode {

    struct Size {
        let width: Float
        let height: Float
        let lenght: Float
    }

    var size: Size {
        let (min, max) = boundingBox
        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
        return .init(width: size.x, height: size.y, lenght: size.x)
    }

}
