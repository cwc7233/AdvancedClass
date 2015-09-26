
//
//  TeacherInfo.swift
//  AdvancedClassStudent
//
//  Created by Harold on 15/9/6.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON
class TeacherInfo {
    var name:String!
    var teacherId:String!
    var title:String!
    var courses = [String]()
    var description:String!
    
    init(json:JSON){
        self.name = json["name"].stringValue
        self.teacherId = json["teacher_id"].stringValue
        self.title = json["title"].stringValue
        for (_,course) in json["courses"]{
            self.courses.append(course["course_name"].stringValue)
        }
        self.description = json["description"].stringValue
    }
    
}