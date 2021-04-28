//
//  MatriceBuilder.swift
//  CVkit
//
//  Created by Faubet Yann on 27/04/2021.
//

import UIKit

struct MatriceBuilder { // Usine => Matrice
    let numberColumns: Int
    let numberRows: Int
    let physicalSize: CGSize

    // MARK: - Methods

    func build() -> Matrice {

        let widthSquare: CGFloat = (physicalSize.width) / CGFloat(numberColumns) // width 4.0
        let heightSquare: CGFloat = (physicalSize.height) / CGFloat(numberRows)  // height 3.92

        print("widthSquare: \(widthSquare)")
        print("heightSquare: \(heightSquare)")
        let sizeSquare = CGSize(width: widthSquare, height: heightSquare)

        var startPoint = CGPoint.zero

        var squares: [Square] = []

        for indexRow in 1..<numberRows+1 { // loop => les lignes
            for indexColumn in 1..<numberColumns+1 { // loop => les colonnes

                let squarePoint = startPoint
                print("row: \(indexRow) - column \(indexColumn) => \(squarePoint)")

                let createSquare = Square(size: sizeSquare, position: squarePoint)

                squares.append(createSquare)
                startPoint.x = squarePoint.x + widthSquare
            }
            startPoint.x = 0
            startPoint.y = startPoint.y + heightSquare
        }

        return Matrice(squares: squares)
    }
}

extension MatriceBuilder {
    static var empty: Matrice {
        return MatriceBuilder(numberColumns: 0, numberRows: 0, physicalSize: CGSize.zero).build()
    }
}
