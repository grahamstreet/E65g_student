//
//  GridView.swift
//  Assignment3
//
//  Created by Graham Street on 3/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//


import UIKit

@IBDesignable class GridView: UIView {
    
    
    @IBInspectable var gridRows: Int = 10
    @IBInspectable var gridCols: Int = 10

    @IBInspectable  var livingColor: UIColor = UIColor.red
    @IBInspectable  var emptyColor: UIColor = UIColor.gray
    @IBInspectable  var bornColor: UIColor = UIColor.green
    @IBInspectable  var diedColor: UIColor = UIColor.yellow
    @IBInspectable  var gridColor: UIColor = UIColor.darkGray
    @IBInspectable  var gridWidth: CGFloat = 3.0
    
    var myGrid: GridViewDataSource?
    
    //end of problem 2

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     */
    
    //problem 4
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        //base
        let base = rect.origin
        
        let cSize = CGSize(
            width: rect.size.width / CGFloat(gridCols),
            height: rect.size.height / CGFloat(gridRows)
        )

        
        
        //gridSize
        let gridSize = CGSize(
            width: rect.size.width / CGFloat(cSize.width),
            height: rect.size.height / CGFloat(cSize.height)
        )
        //draw grid
        (0 ... gridCols).forEach { i in
            //draw vertical lines
            drawLine(
                start: CGPoint(
                    x: base.x + (CGFloat(i) * gridSize.width),
                    y: base.y
                ),
                end: CGPoint(
                    x: base.x + (CGFloat(i) * gridSize.width),
                    y: base.y + rect.size.height
                )
            )
            //draw horizontal lines
            drawLine(
                start: CGPoint(
                    x: base.x,
                    y: base.y + (CGFloat(i) * gridSize.height)
                ),
                end: CGPoint(
                    x: base.x + rect.size.width,
                    y: base.y + (CGFloat(i) * gridSize.height)
                )
            )
            
        }
        //make circles
        
        (0 ..< gridCols).forEach { i in
            
            (0 ..< gridRows).forEach { j in
                
                let circle = UIBezierPath(ovalIn: CGRect(
                    origin: CGPoint (
                        x: base.x + (CGFloat(j) * gridSize.width),
                        y: base.y + (CGFloat(i) * gridSize.height)
                    ),
                    size: gridSize
                    )
                )
                
                var colorToBe = livingColor
                
                
                // TODO: figure out why this had to be optional
                
                if (myGrid?[(i,j)] == .empty) {
                    colorToBe = emptyColor
                } else if (myGrid?[(i,j)] == .born) {
                    colorToBe = bornColor
                } else if (myGrid?[(i,j)] == .died) {
                    colorToBe = diedColor
                }
                
                colorToBe.setFill()
                circle.fill()
                
            }
        }
    }
    
    func drawLine(start: CGPoint, end: CGPoint) {
        let linePath = UIBezierPath()
        //set the path's line width to the width of the stroke
        linePath.lineWidth = gridWidth
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        linePath.move(to: start)
        
        //add a point to the path at the end of the stroke
        linePath.addLine(to: end)
        
        //draw the stroke
        gridColor.setStroke()
        linePath.stroke()
    }
    //end of problem 4
    
    // problem 5
    // touch events
    
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
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        if myGrid != nil {
            myGrid![pos.row, pos.col] = myGrid![pos.row, pos.col].isAlive ? .empty : .alive
        }
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(gridRows)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(gridCols)
        return Position(row: Int(row), col: Int(col))
    }
 
}
