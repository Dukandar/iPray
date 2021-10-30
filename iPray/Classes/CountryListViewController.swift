//
//  CountryListViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 18/04/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
protocol countryList {
    func getCountryList(name:String)
}

class CountryListViewController: UIViewController {
    
    // MARK: - Outlet & Variables
    @IBOutlet var tableview: UITableView!
    var deligate : countryList!
    var countryList = NSArray()
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        countryList = supportingfuction.getThePhoneNumberListArray() as NSArray
        self.tableview.reloadData()
    }
    
    // MARK: - Button Action
    @IBAction func CountryListBtnCliked(_ sender: UIButton)
    {
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableview)
        let cellIndexPath = self.tableview.indexPathForRow(at: pointInTable)! as IndexPath
        let temp = countryList[cellIndexPath.row] as! String
        var componentStringArray = temp.components(separatedBy: "+")
        let object = componentStringArray[1]
        componentStringArray = object.components(separatedBy: ")")
        var countycode = componentStringArray[0]
        countycode = "+" + countycode
        deligate.getCountryList(name: countycode)
        backToPrevious()
    }
    
    @IBAction func backBtnCliked(_ sender: Any) {
        backToPrevious()
    }
        
    func backToPrevious(){
        if self.navigationController != nil {
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TableView Delegate
extension CountryListViewController: UITableViewDataSource , UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kCell)! as UITableViewCell
        let lable = cell.viewWithTag(1) as! UILabel
        lable.text = countryList[indexPath.row] as? String
        cell.selectionStyle = .none
        return cell
    }
}






