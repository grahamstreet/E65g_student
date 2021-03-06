//
//  InstrumentationViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Enhanced by Graham Street on 5/8/17
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit
import Foundation

struct GridContents {
    var name: String
    var cells: [[Int]]
    var maxCount: Int
}

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var gridContents: [GridContents] = []
    
    var engine: StandardEngine!
    
    //MARK: TableView DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gridContents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = gridContents[indexPath.item].name
        return cell
    }
    
    // MARK: UI Outlets, Actions, Inspectables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rowEntry: UITextField!
    @IBOutlet weak var rowStep: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var autoRefresh: UISwitch!
    @IBOutlet weak var refreshIndication: UILabel!
    
    @IBInspectable var backgroundColorForTab : UIColor = UIColor.init(
        red: CGFloat(244/255),
        green: CGFloat(244/255),
        blue: CGFloat(255/255),
        alpha: CGFloat(0.8))
    
    
    @IBAction func rowValueChanged(_ sender: UITextField) {
        guard let rowText = sender.text
            else {return}
        guard let num = Int(rowText) else {
            alert(withMessage: "Hey! that wasn't valid. Stick to numbers please.")
            return
        }
        
        rowStep.value = Double(num)
        StandardEngine.shared().updateRowCol(num: num)
    }
    
    
    @IBAction func rowStep(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        rowEntry.text = "\(numRows)"
        StandardEngine.shared().updateRowCol(num: numRows)
        
        // since rows == cols...
        rowEntry.text = rowEntry.text
        
    }

    
    @IBAction func addRowClick(_ sender: Any) {
        let gridContents = GridContents(name: "untitled", cells: [], maxCount: 10)
        self.gridContents.append(gridContents)
        
        OperationQueue.main.addOperation ({
            self.tableView.reloadData()
        })
    }

    @IBAction func refreshChanged(_ sender: UISlider) {
        if (autoRefresh.isOn) {
            StandardEngine.shared().refreshRate = 0.0
            StandardEngine.shared().refreshRate = TimeInterval(toTimeInterval(sender.value))
        }
        let newRefreshString = String(format: "%.1f", sender.value)
        self.refreshIndication.text = "\(newRefreshString) (hz)"
    }
    

    @IBAction func autoRefreshChanged(_ sender: UISwitch) {
        StandardEngine.shared().refreshRate = TimeInterval(refreshRate.value)

        if sender.isOn {
            StandardEngine.shared().timerOn = true
        } else {
            StandardEngine.shared().timerOn = false
        }
    }
    
    
    // function to invert time adjustment to be sensible
    private func toTimeInterval(_ refreshRate : Float) -> TimeInterval {
        return 1/Double(refreshRate)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        engine = StandardEngine.shared()
    
        // Set up instrumentation display
        self.view.backgroundColor = backgroundColorForTab
        rowEntry.text = "\(StandardEngine.shared().rows)"
        let liveRefreshDisplay = "\(refreshRate.value) hz"
        refreshIndication.text = liveRefreshDisplay
        navigationController?.isNavigationBarHidden = true
        
        // MARK: Get JSON from Professor Simmons' Dropbox
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }

            var maxCount: Int
            var tmp: Int
        
            let jsonArray = json as! NSArray
            
            for i in 0..<jsonArray.count {
                let jsonDictionary = jsonArray[i] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                
                maxCount = 0
                tmp = 0
                for j in 0..<(jsonContents.count) {
                    if (jsonContents[j][0] > jsonContents[j][1]){
                        tmp = jsonContents[j][0]
                    } else {
                        tmp = jsonContents[j][1]
                    }
                    
                    if (tmp > maxCount) {
                        maxCount = tmp
                    }
                    
                }
                let gridContents = GridContents(name: jsonTitle, cells: jsonContents, maxCount: maxCount)
                self.gridContents.append(gridContents)
        
            }
            OperationQueue.main.addOperation ({
                self.tableView.reloadData()
            })
        }

        // MARK: Add a listener for "configuration saves"
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridSave")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                if let contents = n.userInfo?["contents"] as? GridContents {
                    self.gridContents.append(contents)
                    self.tableView.reloadData()
                }
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alert(withMessage msg:String ) {
        let alert = UIAlertController(title: "ALERT", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let gridContent = gridContents[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                vc.gridContents = gridContent
                navigationItem.title = "Cancel"
               
                vc.saveClosure = { newVal in
                    // MARK: Propagate edits back to the table
                    self.gridContents[indexPath.row] = newVal
                    self.tableView.reloadData()

                    // "Activate" the grid in our primary engine to reflect the configuration from GridEditor that was saved.
                    self.engine.updateRowCol(num: 2*gridContent.maxCount)

                    for cell in gridContent.cells {
                        let row = cell[0]
                        let col = cell[1]
                        self.engine.grid[row,col] = CellState.alive
                    }
                }
            }
        }
    }
}

