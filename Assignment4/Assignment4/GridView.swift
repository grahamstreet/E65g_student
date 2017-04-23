//
//  GridView.swift
//  Assignment3
//
//  Created by Graham Street on 3/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//


import UIKit

@IBDesignable class GridView: UIView, GridViewDataSource {
    
    
    @IBInspectable var gridRows: Int = 10
    @IBInspectable var gridCols: Int = 10

    @IBInspectable  var livingColor: UIColor = UIColor.magenta
    @IBInspectable  var emptyColor: UIColor = UIColor.purple
    @IBInspectable  var bornColor: UIColor = UIColor.green
    @IBInspectable  var diedColor: UIColor = UIColor.red
    @IBInspectable  var gridColor: UIColor = UIColor.white
    
    @IBInspectable  var gridWidth: CGFloat = CGFloat(1.0)
    

    var myGrid: GridViewDataSource?
   
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return myGrid![row,col] }
        set { myGrid?[row,col] = newValue }
    }

    override func draw(_ rect: CGRect) {
        // Drawing code
        let base = rect.origin
   
        let size = CGSize(
            width: rect.size.width / CGFloat(self.gridCols),
            height: rect.size.width / CGFloat(self.gridRows)
        )
        
        //draw grid
        (0 ... gridCols).forEach { i in
            //draw vertical lines
            drawLine(
                start: CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y
                ),
                end: CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y + rect.size.height
                )
            
            )
            //draw horizontal lines
            drawLine(
                start: CGPoint(
                    x: base.x,
                    y: base.y + (CGFloat(i) * size.height)
                ),
                end: CGPoint(
                    x: base.x + rect.size.width,
                    y: base.y + (CGFloat(i) * size.height)
                )
            )
            
        }
        
        //make circles
        (0 ..< gridCols).forEach { i in
            
            (0 ..< gridRows).forEach { j in
                
                let origin = CGPoint (
                    x: base.x + (CGFloat(j) * size.width),
                    y: base.y + (CGFloat(i) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                
                let circle = UIBezierPath(ovalIn: subRect)
        
                var colorToBe = livingColor
 
                if (myGrid?[(i,j)] == .empty) {
                    colorToBe = emptyColor
                } else if (myGrid?[(i,j)] == .born) {
                    colorToBe = bornColor
                } else if (myGrid?[(i,j)] == .died) {
                    colorToBe = diedColor
                } else if (myGrid?[(i,j)] == .alive) {
                }

                colorToBe.setFill()
                circle.fill()
                
            }
        }
    }
    
    func drawLine(start: CGPoint, end: CGPoint) {
        let linePath = UIBezierPath()
     
        linePath.lineWidth = gridWidth
        linePath.move(to: start)
        linePath.addLine(to: end)
   
        linePath.stroke()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
        
        let engine = StandardEngine.shared()
        engine.engineUpdateNotify()

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
        setNeedsDisplay()  //^
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
