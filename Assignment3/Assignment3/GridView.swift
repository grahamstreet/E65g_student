//
//  GridView.swift
//  Assignment3
//
//  Created by Graham Street on 3/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable
class GridView: UIView {
    

  
    @IBInspectable  var size: Int = 10 {
        didSet {
            gameGrid = Grid(size, size)
        }
    }

    var gameGrid = Grid(5, 5)
    
    @IBInspectable var livingColor = UIColor.cyan,
                        emptyColor = UIColor.lightGray,
                        bornColor = UIColor.green,
                        diedColor = UIColor.brown,
                        gridColor = UIColor.darkGray
    
    @IBInspectable var gridWidth = CGFloat()
    
    func drawPath( start: CGPoint,
                   end: CGPoint) {
        let path = UIBezierPath()
        path.lineWidth = gridWidth
        
        path.move(to: start)
        path.addLine(to: end)
        gridColor.setStroke()
        path.stroke()
    }
    
   
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let base = rect.origin

        let sizeAsFloat = CGFloat(size)
        
        let gridSize = CGSize(width: rect.size.width / sizeAsFloat,
                              height: rect.size.height / sizeAsFloat)
        
        
        //  Grid Draw
        (0 ..< size + 1).forEach{ i in
            // vert lines
            drawPath(
                start: CGPoint(
                    x: base.x + (CGFloat(i) * gridSize.width),
                    y: base.y),
                end: CGPoint(
                    x: base.x + (CGFloat(i) * gridSize.width),
                    y: base.y + rect.size.height)
            )
            // horiz lines
            drawPath(
                start: CGPoint(
                    x: base.x,
                    y: base.y + (CGFloat(i) * gridSize.height)
                ),
                end: CGPoint(
                    x: base.x + rect.size.width,
                    y: base.y + (CGFloat(i) * gridSize.width)
                )
            )
        }
        //Circle Draw
        (0 ..< size+1).forEach { i in
            (0 ..< size+1).forEach { j in
                
                let circlePath = UIBezierPath(ovalIn: CGRect(
                    origin: CGPoint (
                        x: base.x + (CGFloat(j) * gridSize.width),
                        y: base.y + (CGFloat(i) * gridSize.height)
                    ),
                    size: gridSize
                    )
                )
                
                var birthColor = livingColor
                if (gameGrid[(i,j)] == .empty) {
                    birthColor = emptyColor
                } else if (gameGrid[(i,j)] == .born) {
                    birthColor = bornColor
                } else if (gameGrid[(i,j)] == .died) {
                    birthColor = diedColor
                }
                
                birthColor.setFill()
                circlePath.fill()
                
            }
        }
    }
    
    func nextStage(){
        gameGrid = gameGrid.next()
        setNeedsDisplay()
    }
    
}
