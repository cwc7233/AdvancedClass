//
//  StudentQuestionContentTableViewCell.swift
//  AdvancedClassStudent
//
//  Created by Harold on 16/3/20.
//  Copyright © 2016年 Harold. All rights reserved.
//

import UIKit

class QuestionContentTableViewCell: UITableViewCell {

    @IBOutlet var contentTextView: UITextView!
    var content: String!{
        didSet{
            self.contentTextView?.text = content
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
