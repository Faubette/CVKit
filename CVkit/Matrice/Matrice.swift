//
//  Matrice.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import UIKit

typealias SquareIndex = Int

struct Matrice {
    let squares: [Square] // [Square1 ......... , Sqaure9]

    // MARK: - Methods

    func makeContainer(squareAIndex: SquareIndex, squareBIndex: SquareIndex) -> Square {

        let squareA = squares[squareAIndex - 1]
        let squareB = squares[squareBIndex - 1]

        let origin = squareA.position // (x:0 , Y:0)

        let widthSquare = squareB.position.x - squareA.position.x + squareB.size.width
        let heightSquare = squareB.position.y - squareA.position.y + squareB.size.height
        let sizeSquare = CGSize(width: widthSquare, height: heightSquare)

        return Square(size: sizeSquare, position: origin)
    }
}
// [A , B , C ,D, E].... => count: 5
//  0,  1, 2 , 3 , 4 , 5
extension Matrice {
    var fullscreenSquare: Square {
        let firstIndex = 1
        let lastIndex = squares.count
        return makeContainer(squareAIndex: firstIndex, squareBIndex: lastIndex)
    }
}
