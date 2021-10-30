//
//  LoginNavigationViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 01/04/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit

class RootNavigationViewController: UINavigationController {
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
         self.makeServiceCall()
        // Do any additional setup after loading the view.
    }
    
    private func makeServiceCall() {
        if DefaultsManager.share.isUserLoggedIn()
        {
            Application.RootView.switchToViewControllerWith(identifier: iPrayIdentifier.kBubblesViewController)
        }else{
            Application.RootView.switchToViewControllerWith(identifier: iPrayIdentifier.kHomeViewController)
        }
    }
    
    //SWITCH TO VIEWCONTROLLER
    func switchToViewControllerWith(identifier : String){
        let storyBoard : UIStoryboard = AppStoryboard.Main.instance
        let vcontrol = storyBoard.instantiateViewController(withIdentifier: identifier)
        let navcontrol = UINavigationController.init(rootViewController: vcontrol)
        navcontrol.navigationBar.barTintColor = UIColor().hexColor("#78599E")
        navcontrol.navigationBar.tintColor = UIColor.white
        navcontrol.navigationBar.isTranslucent = false
        navcontrol.navigationBar.isHidden = true
        self.removeChildren()
        Application.RootView.addChild(navcontrol)
        //self.navigationController?.pushViewController(vcontrol, animated: true)
    }
    
    //Remove children From Root view
    func removeChildren(){
        for item in self.children{
            item.removeFromParent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



