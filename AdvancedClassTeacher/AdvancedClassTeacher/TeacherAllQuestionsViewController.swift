//
//  TeacherAllQuestionsViewController.swift
//  AdvancedClassTeacher
//
//  Created by Harold on 16/3/4.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class TeacherAllQuestionsViewController: KnowledgePointViewController {

    @IBOutlet weak var tableView: UITableView!
    override var pointsTableView: UITableView!{
        get{
            return self.tableView
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        print("!")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
