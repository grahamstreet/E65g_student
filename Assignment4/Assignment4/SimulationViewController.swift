//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController , GridViewDataSource, EngineDelegate {
    
    @IBInspectable var backgroundColorForTab : UIColor = UIColor.init(
        red: CGFloat(244/255),
        green: CGFloat(244/255),
        blue: CGFloat(255/255),
        alpha: CGFloat(0.2))
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var stepButton: UIButton!
  
    var engine: StandardEngine!
    var delegate: EngineDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColorForTab
        
        engine = StandardEngine.shared()
        engine.delegate = self
        gridView.myGrid = self
        self.gridView.gridRows = engine.rows
        self.gridView.gridCols = engine.cols
        
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.gridRows = StandardEngine.shared().rows
        self.gridView.gridCols = StandardEngine.shared().cols
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    @IBAction func stepButtonAction(_ sender: UIButton) {
        engine.grid = engine.step()
    }


}

