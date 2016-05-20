//
//  LaunchScreenViewController.swift
//  PeekCodingChallenge
//
//  Created by Cristián Garay on 5/20/16.
//  Copyright © 2016 Cristian Garay. All rights reserved.
//

import UIKit

/*
MARK: Splash screen for app
*/

class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(#selector(LaunchScreenViewController.showNavContoller), withObject: nil, afterDelay: 3)
        
    }
    
    func showNavContoller() {
        performSegueWithIdentifier("showLaunchScreen", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
