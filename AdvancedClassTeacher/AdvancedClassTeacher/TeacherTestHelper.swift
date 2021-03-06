//
//  BaseTestHelper.swift
//  MyClassStudent
//
//  Created by Harold on 15/8/16.
//  Copyright (c) 2015年 Harold. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
protocol TeacherNewTestDelegate{
    func questionAdded(currentQuestionNum: Int)
    func questionRemoved(currentQuestionNum: Int)
}

class TeacherTestHelper {
    
    static var _defaultHelper: TeacherTestHelper?
    static var defaultHelper:TeacherTestHelper{
        get{
            if _defaultHelper == nil{
                _defaultHelper = TeacherTestHelper()
            }
            return _defaultHelper!
        }
    }
    var currentTest: TeacherTest!
    private var delegate: TeacherNewTestDelegate?
    private var _newTest: TeacherTest!

    var newTest: TeacherTest{
        get{
            if self._newTest == nil{
                self._newTest = TeacherTest.getNewTest()
            }
            return self._newTest
        }
    }
    
    func dropNewTest(){
        self._newTest = nil
    }
    
    
    
    func postNewTest(course: TeacherCourse?=nil, completionHandler: ResponseMessageHandler){
        var dict = self.newTest.toDict()
        let course = course ?? TeacherCourse.currentCourse!
        dict["course_id"] = course.courseId
      
        
        TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(RequestType.POST_TEST, parameters: dict){
            [unowned self]
            (error, json) in
            if error == nil{
                self.newTest.testId = json["test_id"].stringValue
                course.unfinishedTests.insert(self.newTest, atIndex: 0)
                self.dropNewTest()

            }
            completionHandler(error: error)
        }
    }
    
    
    func getUnfinishedTestsInCourse(course: TeacherCourse, completionHandler: ResponseMessageHandler){
        TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(RequestType.GET_UNFINISHED_TESTS, parameters: ["course_id": course.courseId]){
            (error, json) in
            if error == nil{
                course.unfinishedTests = [TeacherTest]()
                for (_, test_json) in json["tests"]{
                    let test = TeacherTest(json: test_json)
                    course.unfinishedTests.append(test)
                    course.testsDict[test.testId] = test
                }
            }
            completionHandler(error: error)
            
        }
    }
    
    func getFinishedTestsInCourse(course: TeacherCourse, page: Int, completionHandler: ResponseMessageHandler){
        assert(page >= 1)
        
        TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(RequestType.GET_FINISHED_TESTS, parameters: ["course_id":course.courseId, "page": page, "descending": true]){
            (error, json) in
            if error == nil{
                course.finishedTests = [TeacherTest]()
                for (_, n) in json["tests"]{
                    let test = TeacherTest(json: n)
                    course.finishedTests.append(test)
                }
            }
            completionHandler(error: error)
        }

    }
    
    
    func getQuestionsWithQuestionIds(questionIds: [String], test: TeacherTest, completionHandler: ResponseMessageHandler){
        TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(.GET_QUESTIONS_IN_LIST, parameters: ["questions": questionIds]){
            (error, json) in
            if error == nil{
                for (_, question_json) in json["questions"]{
                    test.addQuestionForResults(TeacherQuestion(json: question_json))
                }
            }
            completionHandler(error: error)
            
            
        }
    }
    
    func endTest(test: TeacherTest, completionHandler: ResponseMessageHandler){
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOSTWithCourse(RequestType.END_TEST, parameters: ["test_id": test.testId]){
            (error, json) in
            if error == nil{
                test.finished = true
                let course = TeacherCourse.currentCourse
                course.finishedTests.insert(test, atIndex: 0)
                course.unfinishedTests.removeAtIndex(course.unfinishedTests.indexOf({$0 === test})!)
            }
            completionHandler(error: error)
        }
    }
    
    func deleteTest(test: TeacherTest, completionHandler: ResponseMessageHandler){
        if !test.finished{
            completionHandler(error: nil)
        }
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOSTWithCourse(RequestType.DELETE_TEST, parameters: ["test_id": test.testId]){
            (error, json) in
            if error == nil{
                let course = TeacherCourse.currentCourse
                course.finishedTests.removeAtIndex(course.finishedTests.indexOf({$0 === test})!)
            }
            completionHandler(error: error)
        }
    }
    


    func getTestResultsMain(test: TeacherTest, completionHandler: ResponseMessageHandler){
        TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(RequestType.GET_TEST_RESULTS, parameters: ["test_id": test.testId]){
            [unowned self]
            (error, json) in
            if error == nil{
                test.results = TestResult()
                test.results.getResultsFromJSON(json["results"])
                test.resultAcquired = true
            }
            
            self.getQuestionsWithQuestionIds(test.results.tempQuestionIds, test: test, completionHandler: completionHandler)
        }
    }

    
    func getTestResults(test: TeacherTest, completionHandler: ResponseMessageHandler){
        if !test.finished{
            completionHandler(error: MyError(cerror: CError.TEST_STILL_ONGOING))
            return
        }
        else{
            if TeacherCourse.currentCourse.syllabus == nil{
                TeacherCourseHelper.defaultHelper.getSyllabus{
                    error in
                    if let error = error{
                        completionHandler(error: error)
                    }
                    else{
                        self.getTestResultsMain(test, completionHandler: completionHandler)
                    }
                }
            }
            else{
                self.getTestResultsMain(test, completionHandler: completionHandler)
            }
        }
    }
    

    
    func getUntakenStudents(test: TeacherTest, completionHandler: ResponseMessageHandler){
        if test.finished && test.unfinishedStudents != nil{
            completionHandler(error: nil)
        }
        else{
            TeacherAuthenticationHelper.defaultHelper.getResponsePOSTWithCourse(RequestType.GET_UNFINISHED_STUDENTS, parameters: ["test_id": test.testId]){
                (error, json) in
                if error == nil{
                    test.unfinishedStudents = [String]()
                    for (_, studentId) in json["students"]{
                        test.unfinishedStudents.append(studentId.stringValue)
                    }
                    let untaken = Set<String>(test.unfinishedStudents)
                    let all = Set<String>(TeacherCourse.currentCourse.studentDict.keys)
                    test.finishedStudents = [String](all.subtract(untaken))
                }
                completionHandler(error: error)
            }
        }
        
        
    }

    
    
}