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
    
  
    @IBInspectable  var size: Int = 20 {
        didSet {
            gameGrid = Grid(size, size)
        }
    }

    @IBInspectable var btn = UIButton()
    
    var gameGrid = Grid(20,20)
    
    @IBInspectable var livingColor = UIColor(),
                        emptyColor = UIColor(),
                        bornColor = UIColor(),
                        diedColor = UIColor(),
                        gridColor = UIColor()
    
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
        
        gameGrid.positions.forEach { pos in
        
            print("pos: \(pos) state:\(gameGrid[pos])")
          
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil}
        let p = positionToCell(touch: touches.first!)
        guard lastTouchedPosition?.row != p.row
            || lastTouchedPosition?.col != p.col
            else { return p }
    
        gameGrid[p] = gameGrid[p].toggle(value: gameGrid[p])
        setNeedsDisplay()
        return p
    
    }
    
    func positionToCell(touch: UITouch) -> Position {
        
        let gridHeight = frame.size.height
        let gridWidth = frame.size.width
        
        let touchY = touch.location(in: self).y
        let touchX = touch.location(in: self).x
        
        let row = touchY / gridHeight * CGFloat(size)
        let col = touchX / gridWidth * CGFloat(size)
        
        return (row: Int(row), col: Int(col))
    }
        
    

    public func nextStage(){
        
        print("nextStage")
        gameGrid = gameGrid.next()
        setNeedsDisplay()
    }
    
}
