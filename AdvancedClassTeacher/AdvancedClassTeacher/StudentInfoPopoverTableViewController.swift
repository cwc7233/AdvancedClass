//
//  StudentInfoPopoverTableViewController.swift
//  AdvancedClassStudent
//
//  Created by Harold on 16/2/25.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class StudentInfoPopoverTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        self.tableView.separatorStyle = .None
    }
    
    var student: Student?
    
    override var preferredContentSize: CGSize{
        get{
            return self.tableView.frame.size
        }
        set{
            self.tableView.frame.size = newValue
            super.preferredContentSize = newValue
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        defer { cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero }
        var cell: UITableViewCell
        if indexPath.row == 0{
            cell = self.tableView.dequeueReusableCellWithIdentifier("PhotoCell")!
            cell.textLabel?.text = self.student?.studentId ?? "未知"
            cell.imageView?.contentMode = .ScaleAspectFit
            if let avatar = self.student?.avartar{
                cell.imageView?.image = avatar
            }
            else{
                cell.imageView?.image = UIImage(named: "NO_AVATAR_MALE")
            }
            return cell
        }
        cell = self.tableView.dequeueReusableCellWithIdentifier("TextCell")!
        switch indexPath.row{
        case 1:
            cell.textLabel?.text = "姓名"
            cell.detailTextLabel?.text = self.student?.name ?? "未知"
        case 2:
            cell.textLabel?.text = "班级"
            cell.detailTextLabel?.text = self.student?.className ?? "未知"
        default:
            return cell
        }
        
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
   
}
