//
//  StudentMultipleChoiceTableViewCell.swift
//  AdvancedClassStudent
//
//  Created by Harold on 16/3/20.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class MultipleChoiceTableViewCell: UITableViewCell {
    
    
    
    
    @IBOutlet var myImageView: UIImageView!

    @IBOutlet var choiceLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    var content: String!{
        didSet{
            self.choiceLabel?.text = content
        }
        
    }
    var detailText: String!{
        didSet{
            self.rightLabel?.text = self.detailText
        }
    }
    
    var correct: Bool?{
        didSet{
            if let correct = self.correct{
                if correct{
                    self.myImageView.image = UIImage(named: "correct")
                    self.layer.borderColor = UIColor.blueColor().CGColor
                }
                else{
                    self.myImageView.image = UIImage(named: "incorrect")
                    self.layer.borderColor = UIColor.redColor().CGColor
                }
            }
        }
    }
    
    var choiceNumber: Int!{
        didSet{
            if let number = choiceNumber{
                var choice: String
                switch number{
                case 0:
                    choice = "A"
                case 1:
                    choice = "B"
                case 2:
                    choice = "C"
                case 3:
                    choice = "D"
                case 4:
                    choice = "E"
                case 5:
                    choice = "F"
                case 6:
                    choice = "G"
                default:
                    choice = ""
                }
                self.myImageView?.image = UIImage(named: choice)
            }
        }
    }
    
    
}
