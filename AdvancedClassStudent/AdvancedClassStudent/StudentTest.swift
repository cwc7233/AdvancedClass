//
//  TestClass.swift
//  AdvancedClassTeacher
//
//  Created by Harold on 15/9/3.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON
class StudentTest{
    
    var questionIds = [String]()
    var questions = Dictionary<String,Question>()
    var questionArray = [Question]()
    var id = ""
    var hasHint = false
    var timeLimitInt = -1
    var _timeLimitDict:Dictionary<String,Int>?
    var courseId:String!
    var expired = false
    var startTime = ""
    var deadline = ""
    var randomNumber = 0
    var message = ""
    var total = 0
    var _current = 0
    var doneAcquiring = false
    var finished = false
    var results = Dictionary<String,String>()
    
    
    var current:Int{
        get{
            return self._current
        }
        set{
            self._current = newValue
            if newValue == self.total{
                self.doneAcquiring = true
            }
        }
    }
    
    init(json:JSON){
        for (_,questionId) in json["question_list"]{
            self.questionIds.append(questionId.stringValue)
        }
        self.id = json["_id"].stringValue
        self.hasHint = json["has_hint"].boolValue
        self.timeLimitInt = json["time_limit"].intValue
        self.courseId = json["course_id"].stringValue
        self.expired = json["expired"].boolValue
        self.startTime = json["start_time"].stringValue
        self.deadline = json["deadline"].stringValue
        self.message = json["message"].stringValue
        self.randomNumber = json["random_num"].intValue
        if self.randomNumber == 0{
            self.total = self.questionIds.count
        }
        else{
            self.total = self.randomNumber
        }
    }
    
    func addAcquiredQuestion(question:Question){
        self.questions[question.id] = question
        self.questionArray.append(question)
        self.current = self.current + 1
        
    }
    
    
    
    func undoAll(){
        for q in self.questionArray{
            q.result = ["my_choice":"N","is_correct":false]
        }
    }
    
    func getQuestionList() -> [String]{
        var temp = [String]()
        for (_,question) in self.questions{
            temp.append(question.id)
        }
        return temp
    }
    
}
