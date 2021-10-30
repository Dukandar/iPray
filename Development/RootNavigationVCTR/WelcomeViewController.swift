//
//  WelcomeViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button Action
    @IBAction func addNewPrayer(_ sender: UIButton) {
        let welcome = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kBubblesViewController) as! BubblesViewController
        self.navigationController?.pushViewController(welcome, animated: true)
    }
    
}
