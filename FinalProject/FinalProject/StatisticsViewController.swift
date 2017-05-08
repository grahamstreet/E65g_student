//
//  FrameAndBoundsViewController.swift
//  FinalProject
//
//  Created by Graham Street on 4/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    // Shows now that it knows the type
    @IBInspectable var backgroundColorForTab :
        UIColor = UIColor.init(
            red: CGFloat(244/255),
            green: CGFloat(255/255),
            blue: CGFloat(244/255),
            alpha: CGFloat(0.8))
    
    @IBOutlet weak var aliveCount: UILabel!
    @IBOutlet weak var bornCount: UILabel!
    @IBOutlet weak var deadCount: UILabel!
    @IBOutlet weak var emptyCount: UILabel!
    
    let engine = StandardEngine.engine
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColorForTab
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(forName: name, object: nil, queue: nil) { (x) in
            self.updateStats()
        }
        updateStats()
    }
 

    
    func updateStats() {
        engine.updateCounts(myGrid: engine.grid)
        
        aliveCount.text = "\(StandardEngine.shared().aliveCount)"
        bornCount.text = "\(StandardEngine.shared().bornCount)"
        deadCount.text = "\(StandardEngine.shared().deadCount)"
        emptyCount.text = "\(StandardEngine.shared().emptyCount)"
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        engine.updateCounts(myGrid: engine.grid)
  
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
