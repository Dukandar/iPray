//
//  CreateGroupViewController.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 21/11/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//
import UIKit
import AFNetworking
import SafariServices
class CreateGroupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var placeholder = ["Group Name","Group Description","Group Password (Optional)"]
    var dataArray = NSMutableArray()
    var isSecured : Bool = false
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableView.automaticDimension
        dataArray.add("")
        dataArray.add("")
        dataArray.add("")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.reloadData()
    }
    
    // MARK: - Button Action
    @IBAction func groupAgreementButtonPress(_ sender: UIButton)
    {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: URL(string:  iPrayConsant.kUserAgreement)!, configuration: config)
        present(vc, animated: true)
        
    }
    
    @IBAction func UnhidePassword(_ sender: UIButton)
    {
        if sender.isSelected == true {
            sender.isSelected = false
            isSecured = false
        }else{
            sender.isSelected = true
            isSecured = true
        }
        tableView.reloadData()
    }
    
    @IBAction func backButtonPress(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createGroupButtonPress(_ sender: UIButton)
    {
        self.view.endEditing(true)
         if (dataArray.object(at: 0) as! String).trimmingCharacters(in: CharacterSet.whitespaces)=="" {
            
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.GroupName,delay: ConstantMessage.kDelay)
            return
        }else
        {
            // hit web service
            self.createGroupWebService()
        }
    }
}

// MARK: - TableView Delegate
extension CreateGroupViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell!
        if indexPath.row == 0 {
            cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLogoCell)! as UITableViewCell
            let bgView = cell.viewWithTag(1) as UIView?
            let path = UIBezierPath(roundedRect:(bgView?.bounds)!,
                                    byRoundingCorners:[.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10, height:  10))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            bgView?.layer.mask = maskLayer
            
        }else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3{
            cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextfieldCell)! as UITableViewCell
            let bgView = cell.viewWithTag(2) as UIView?
            let textFld = cell.viewWithTag(21) as! UITextField
            let secureBtn = cell.viewWithTag(22) as! UIButton
            
            bgView?.layer.cornerRadius=20
            textFld.placeholder = placeholder[indexPath.row - 1]
            
            if indexPath.row == 3 {
                secureBtn.isHidden = false
                if isSecured{
                    textFld.isSecureTextEntry = false
                }else{
                    textFld.isSecureTextEntry = true
                }
            }else{
                secureBtn.isHidden = true
            }
        }else if indexPath.row == 4 {
            cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kStaticCell)! as UITableViewCell
        }else if indexPath.row == 5 {
            cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kSubmitCell)! as UITableViewCell
            let bgView = cell.viewWithTag(4) as UIView?
            let btnView = cell.viewWithTag(41) as UIView?
            _ = cell.viewWithTag(42) as! UIButton
            
            btnView?.layer.cornerRadius=20
            btnView?.layer.borderWidth=1.2
            btnView?.layer.borderColor=UIColor(red: 254.0/255.0, green: 221.0/255.0, blue: 172.0/255.0, alpha: 1).cgColor
            
            let path = UIBezierPath(roundedRect:(bgView?.bounds)!,
                                    byRoundingCorners:[.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 10, height:  10))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            bgView?.layer.mask = maskLayer
            
            
        }else{
            cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kBottomCell)! as UITableViewCell
        }
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension CreateGroupViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let textFieldIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        
        if (textFieldIndexPath?.row)! > 0 && (textFieldIndexPath?.row)! < 4 {
            dataArray.replaceObject(at: (textFieldIndexPath?.row)! - 1, with: textField.text!)
        }
    }
}

// MARK: - Web Service
extension CreateGroupViewController
{
    //MARK: get user details Webservice
    func createGroupWebService()
    {
        var isPublic = 0
        if (dataArray.object(at: 2) as! String).trimmingCharacters(in: CharacterSet.whitespaces)=="" {
        isPublic = 1
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(dataArray.object(at: 0), forKey: ConstantMessage.kGroupName)
        perameter.setValue(dataArray.object(at: 1), forKey: ConstantMessage.kGroupDecription)
        perameter.setValue(dataArray.object(at: 2), forKey: ConstantMessage.kGroupPassword)
        perameter.setValue(isPublic, forKey: ConstantMessage.kIsPublic)
        ServiceUtility.callWebService(CREATE_GROUP_URl, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kUploadGroupImageViewController) as! UploadGroupImageViewController
                    vc.groupData = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }else
                {
                    self.dataArray.replaceObject(at: 2, with: "")
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

