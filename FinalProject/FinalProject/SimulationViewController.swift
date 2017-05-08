//
//  SimulationViewController.swift
//  FinalProject
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
        alpha: CGFloat(0.8))
    
    
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
                print("Notification in sim viewcontroller in observed. \(n)")
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

    @IBAction func save(_ sender: UIButton) {
        let prompt = UIAlertController(title: "Grid Save", message: "", preferredStyle: .alert)
        
        prompt.addAction(
            UIAlertAction(title: "Save", style: .default) { (_) in
            if let name = prompt.textFields?[0] {
                if let name = name.text {
                    if (name.characters.count < 1) {
                        let emptyName = UIAlertController(title: "Error", message:
                            "Name should at least be a character!", preferredStyle: UIAlertControllerStyle.alert)
                        emptyName.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(emptyName, animated: true, completion: nil)
                    } else {

                        var gridContents = GridContents(name: name, cells: [], maxCount: self.engine.grid.size.cols)
                        gridContents.cells = []
                        (0 ..< self.engine.grid.size.rows).forEach { row in
                            (0 ..< self.engine.grid.size.cols).forEach { col in
                                let cell = self.engine.grid[row,col]
                                if (cell.isAlive) {
                                    gridContents.cells.append([row,col])
                                }
                            }
                        }
                        
                        // let the instrumentation table know about this new config.
                        self.gridSaveNotify(contents: gridContents)
                        
                        let success = UIAlertController(title: "Success", message:
                            "Saved configuration to list on Instrumentation tab.", preferredStyle: UIAlertControllerStyle.alert)
                        success.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(success, animated: true, completion: nil)
                    }
                }
            }
        })
        
        prompt.addTextField { (textField) in
            textField.placeholder = "Give this pattern a name"
        }
        
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in })
        
        self.present(prompt, animated: true, completion: nil)
    }

    public func gridSaveNotify( contents: GridContents)
    {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridSave")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["contents" : contents])
        nc.post(n)
    }



}

