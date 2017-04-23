//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit
import Foundation




class InstrumentationViewController: UIViewController {
    
    @IBOutlet weak var rowEntry: UITextField!
    @IBOutlet weak var colEntry: UITextField!
    @IBOutlet weak var rowStep: UIStepper!
    @IBOutlet weak var colStep: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var autoRefresh: UISwitch!

    @IBOutlet weak var refreshIndication: UILabel!
    // Shows now that it knows the type
    
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
        
        // since rows == cols,  update cols too.
        colStep.value = Double(num)
        StandardEngine.shared().updateRowCol(num: num)
        colEntry.text = rowEntry.text
    }
    
    @IBAction func colValueChanged(_ sender: UITextField) {
        guard let colText = sender.text
            else {return}
        guard let num = Int(colText) else {
            alert(withMessage: "Hey! that wasn't valid. Stick to numbers please.")
            return
        }
        
        colStep.value = Double(num)
        StandardEngine.shared().updateRowCol(num: num)
        
        // since rows == cols,  update rows too.
        rowStep.value = Double(num)
        StandardEngine.shared().updateRowCol(num: num)
        
        rowEntry.text = colEntry.text
    }

    
    @IBAction func rowStep(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        rowEntry.text = "\(numRows)"
        StandardEngine.shared().updateRowCol(num: numRows)
        
        // since rows == cols...
        colEntry.text = rowEntry.text
        
    }
    
    @IBAction func colStep(_ sender: UIStepper) {
        let numCols = Int(sender.value)
        colEntry.text = "\(numCols)"
        StandardEngine.shared().updateRowCol(num: numCols)
        
        // since rows == cols...
        rowEntry.text = colEntry.text
    }
    
    private func toTimeInterval(_ refreshRate : Float) -> TimeInterval {
        return 1/Double(refreshRate)
    }
    

    @IBAction func refreshChanged(_ sender: UISlider) {
        if (autoRefresh.isOn) {
            StandardEngine.shared().refreshRate = 0.0
            StandardEngine.shared().refreshRate = TimeInterval(toTimeInterval(sender.value))
        }
        let newRefreshString = String(format: "%.1f", sender.value)
        self.refreshIndication.text = "\(newRefreshString) (hz)"
        print("refreshRate \(StandardEngine.shared().refreshRate)")
    }
    
    

    
    @IBAction func autoRefreshChanged(_ sender: UISwitch) {
    
        StandardEngine.shared().refreshRate = TimeInterval(refreshRate.value)

        if sender.isOn {
            StandardEngine.shared().timerOn = true
            print("shared timer turned on. refreshRate \(StandardEngine.shared().refreshRate)")
        } else {
            StandardEngine.shared().timerOn = false
            print("shared timer turned off.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = backgroundColorForTab
        rowEntry.text = "\(StandardEngine.shared().rows)"
        colEntry.text = "\(StandardEngine.shared().cols)"
        let liveRefreshDisplay = "\(refreshRate.value) hz"
        refreshIndication.text = liveRefreshDisplay
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alert(withMessage msg:String ) {
        // create the alert
        let alert = UIAlertController(title: "ALERT", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

}

