//
//  FrameAndBoundsViewController.swift
//  Assignment4
//
//  Created by Graham Street on 4/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    // Shows now that it knows the type
    @IBInspectable var backgroundColorForTab : UIColor = UIColor.clear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColorForTab
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
