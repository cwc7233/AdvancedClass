//
//  Course.swift
//  AdvancedClassTeacher
//
//  Created by Harold on 15/9/7.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


class KnowledgePoint{
    var knowledgePointId: String!
    var content: String!
    var level: Int!
    var questions = [TeacherQuestion]()
    var questionsAcquired = false
    var chapterNum: Int!
    var sectionNum: Int!
    var questionNum: Int!
    init(json: JSON){
        self.knowledgePointId = json["point_id"].stringValue
        self.content = json["content"].stringValue
        self.level = json["level"].intValue
        self.questionNum = json["question_num"].intValue
    }
    
    func getQuestions(completionHandler: ResponseHandler){
        if self.questionsAcquired{
            completionHandler(error: nil, json: nil)
            return
        }
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOST(.GET_QUESTIONS_IN_POINT, postBody: ["course_id": TeacherCourse.currentCourse.courseId, "sub_id": TeacherCourse.currentCourse.subId, "point_id": self.knowledgePointId]){
            [unowned self]
            (error, json) in
            if error == nil{
                for (_, json) in json["questions"]{
                    let q = TeacherQuestion.createPreview(json)
                    q.knowledgePointId = self.knowledgePointId
                    self.questions.append(q)
                    
                }
                self.questionsAcquired = true
                completionHandler(error: nil, json: nil)
            }
            else{
                completionHandler(error: error, json: nil)
                self.questionsAcquired = false
            }
        }
    }
    
}

class Section{
    var sectionName: String!
    var chapterNum: Int!
    var sectionNum: Int!
    var plannedHours: Int!
    var knowledgePoints = [KnowledgePoint]()
    var knowledgePointsDict = [String: KnowledgePoint]()
    init(json: JSON){
        self.sectionName = json["section_name"].stringValue
        self.chapterNum = json["chapter_num"].intValue
        self.sectionNum = json["section_num"].intValue
        for (_, point_dict) in json["points"]{
            self.addKnowledgePoint(KnowledgePoint(json: point_dict))
            
        }
    }
    
    func addKnowledgePoint(point: KnowledgePoint){
        self.knowledgePoints.append(point)
        self.knowledgePointsDict[point.knowledgePointId] = point
    }
}

class Chapter{
    var chapterNum: Int!
    var chapterName: String!
    var sections = [Section]()
    var sectionsDict = [Int: Section]()
    init(json: JSON){
        self.chapterName = json["chapter_name"].stringValue
        self.chapterNum = json["chapter_num"].intValue
        for (_, section_dict) in json["sections"]{
            self.addSection(Section(json: section_dict))
        }
    }
    
    func addSection(section: Section){
        self.sections.append(section)
        self.sectionsDict[section.sectionNum] = section
    }


}

class Syllabus{
    var chapters = [Chapter]()
    var chaptersDict = [Int: Chapter]()
    var knowledgePoints = [String: KnowledgePoint]()
    func getChapterWithChapterNum(chapterNum: Int) -> Chapter?{
        return self.chaptersDict[chapterNum]
    }
    func getSectionWithChapterNum(chapterNum: Int, sectionNum: Int) -> Section?{
        return self.chaptersDict[chapterNum]?.sectionsDict[sectionNum]
    }
    init(json: JSON){
        for (_, chapter_dict) in json["chapters"]{
            self.addChapter(Chapter(json: chapter_dict))
        }
       // self.chapters.sortInPlace({$0.chapterNum < $1.chapterNum})
    }
    
    func addChapter(chapter: Chapter){
        self.chapters.append(chapter)
        self.chaptersDict[chapter.chapterNum] = chapter
        for section in chapter.sections{
            for point in section.knowledgePoints{
                self.knowledgePoints[point.knowledgePointId] = point
            }
        }
    }
    
}


class Notification {
    var title:String!
    var content:String!
    var onTop: Bool!
    var createdOn:String!
    var createdOnTimeData:NSDate!
    var notificationId:String!
    var courseName = ""
    init(json:JSON){
        self.title = json["title"].stringValue
        self.content = json["content"].stringValue
        self.onTop = json["on_top"].boolValue
        self.notificationId = json["ntfc_id"].stringValue
        self.createdOn = json["created_on"].stringValue
        
    }
    
    init(){}
    
    func toDict() -> Dictionary<String,AnyObject>{
        var a = ["title": self.title, "on_top": self.onTop, "content":self.content] as! Dictionary<String, AnyObject>
        if let id = self.notificationId{
            a["ntfc_id"] = id
        }
        return a
    }
}

class TeacherCourse {
    static var currentCourse: TeacherCourse!
    
    var studentIdList = [String]()
    var name:String
    var courseId:String
    var subId:String
    var teachers = [String]()
    var timesAndRooms: TimesAndRooms
    var unfinishedTests = [TeacherTest]()
    var testsDict = [String: TeacherTest]()
    var finishedTests = [TeacherTest]()
    var students = [String: Student]()
    var studentIds = [String]()
    var notifications = [Notification]()
    var syllabus: Syllabus!
    init(json:JSON, preview:Bool = true){
        self.name = json["course_name"].stringValue
        self.courseId = json["course_id"].stringValue
        self.subId = json["sub_id"].stringValue
        self.timesAndRooms = TimesAndRooms(json: json["times"])
    }
    
    
    
    
}