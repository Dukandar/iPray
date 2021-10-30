//
//  HomeViewController.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 10/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import SafariServices

class HomeViewController: UIViewController {
    
    // MARK: - Outlets & variables
    @IBOutlet weak var homeTableView: UITableView!
    
    // MARK: - Variables
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeTableView.estimatedRowHeight = 145
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        self.homeTableView.reloadData()
    }
    
    //MARK:- IBAction
    @IBAction func logInAction(_ sender: UIButton) {
        let login = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kLoginViewController) as! LoginViewController
        self.navigationController?.pushViewController(login, animated: true)
    }
    
    @IBAction func termAndConditionBtnCliked(_ sender: UIButton) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: URL(string: iPrayConsant.kPrivacypolicy)!, configuration: config)
        present(vc, animated: true)
    }
}

// MARK: - TableView Delegate
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLogoCell)! as UITableViewCell
             return cell
        case 3:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kButtonCell)! as UITableViewCell
            if #available(iOS 13, *) {
                self.signInWithApple(cell: cell)
            }else{
                cell.viewWithTag(1)!.isUserInteractionEnabled = false
                cell.viewWithTag(1)!.alpha = 0.4
                cell.viewWithTag(1)!.backgroundColor = UIColor.lightGray
            }
            return cell
        case 4:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLoginCell)! as UITableViewCell
            return cell
        default:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kButtonCell)! as UITableViewCell
            let dictionary = self.filedNames[(indexPath.row - 1)] as! NSDictionary
            cell.viewWithTag(1)!.backgroundColor = returnViewBackgroundColorWith(index: indexPath.row)
            (cell.viewWithTag(11) as! UIImageView).image = UIImage(named : dictionary.value(forKey: ConstantMessage.kFieldImage) as! String)
            (cell.viewWithTag(12) as! UILabel).text = (dictionary.value(forKey: ConstantMessage.kFieldName) as! String)
            return cell
        }
    }
    
    func returnViewBackgroundColorWith(index : Int)-> UIColor {
        switch index {
        case 1:return UIColor(red: 45.0/255.0, green: 68.0/255.0, blue: 135.0/255.0, alpha: 1)
        case 2:return UIColor(red: 249.0/255.0, green: 80.0/255.0, blue: 105.0/255.0, alpha: 1)
        default:break
        }
        return UIColor.clear
    }
    
    // Cell View Button Action
    @IBAction func createAccount(_ sender: UIButton) {
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.homeTableView)
        let indexPath = self.homeTableView.indexPathForRow(at: pointInTable)
        switch indexPath?.row {
        case 1:
             loginFacebookRequest()
        default:
            let accountCreate = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAccountCreateViewController) as! AccountCreateViewController
            self.navigationController?.pushViewController(accountCreate, animated: true)
        }
    }
}

//MARK:- Field Data
extension HomeViewController {
    
    func returnFieldNames()-> NSArray{
        return [[ConstantMessage.kFieldName:"SIGN IN WITH FACEBOOK","fieldImage" :"facebooklogo_login_Image"],
                [ConstantMessage.kFieldName:"CREATE ACCOUNT WITH EMAIL","fieldImage" :"email_createAccount_button_Image"],
                [ConstantMessage.kFieldName:"SIGN IN WITH APPLE","fieldImage" :"email_createAccount_button_Image"]]
    }
    
    func returnParamFields()-> NSDictionary{
        return ["fields" :"id, name, email , gender"]
    }
}

//MARK:-
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

