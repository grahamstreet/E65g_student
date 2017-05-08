//
//  GridEditorViewController.swift
//  Lecture11
//
//  Created by Van Simmons on 4/17/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {
    
    var saveClosure: ((GridContents) -> Void)?
    var gridContents: GridContents?
    var temporaryEngine: StandardEngine!
    var editState: StandardEngine!

    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var editableNameField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        if gridContents != nil {
            temporaryEngine = StandardEngine(rows: 2*gridContents!.maxCount, cols: 2*gridContents!.maxCount, refreshRate:1.0)
            self.gridView.gridRows = temporaryEngine.rows
            self.gridView.gridCols = temporaryEngine.cols
            
            for cell in gridContents!.cells {
                let row = cell[0]
                let col = cell[1]
                temporaryEngine.grid[row,col] = CellState.alive
            }
            
            gridView.myGrid = self
            //editState.delegate = self.editState
            self.editableNameField.text? = gridContents!.name
            //self.navigationController?.navigationBar.topItem?.title = gridStruct?.name
            
            gridView.setNeedsDisplay()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    public subscript (row: Int, col: Int) -> CellState {
        get { return temporaryEngine.grid[row,col] }
        set { temporaryEngine.grid[row,col] = newValue }
    }


    @IBAction func saveClick(_ sender: Any) {
        
        
        gridContents!.name = editableNameField.text!
        gridContents!.cells = []
        (0 ..< temporaryEngine.grid.size.rows).forEach { row in
            (0 ..< temporaryEngine.grid.size.cols).forEach { col in
                let cell = temporaryEngine.grid[row,col]
                if (cell.isAlive) {
                    gridContents!.cells.append([row,col])
                }
            }
        }
        if let newValue = gridContents,
            let saveClosure = saveClosure {
            
            saveClosure(newValue)
            print("save closure invoked with \(newValue)")
            
            // Per instructs:  'Clicking a "Save" button on the GridEditor should cause the user to return to the main instrumentation page.'
            self.navigationController?.popViewController(animated: true)
        }

        
    }
   

}
