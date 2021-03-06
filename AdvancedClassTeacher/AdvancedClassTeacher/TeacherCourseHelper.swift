

class TeacherCourseHelper{
    static var _defaultHelper: TeacherCourseHelper?
    static var defaultHelper: TeacherCourseHelper!{
        get{
            if TeacherCourseHelper._defaultHelper == nil{
                TeacherCourseHelper._defaultHelper = TeacherCourseHelper()
            }
            return TeacherCourseHelper._defaultHelper
        }
    }
    
    
    class AttendanceList{
        var absentStudents: [String] = []
        var seatMap: [String: String] = [:]
        var presentStudents: [String] = []
        var askedStudents: [String]! = []
        
    }
    var attendanceList = AttendanceList()
    
    func getNotifications(course: TeacherCourse, page: Int, completionHandler: ResponseMessageHandler){
        assert(page >= 1)
       
            TeacherAuthenticationHelper.defaultHelper.getResponsePOST(RequestType.GET_NOTIFICAIONS, parameters: ["course_id":course.courseId, "page": 1]){
                (error, json) in
                if error == nil{
                    course.notifications = [Notification]()
                    for (_, n) in json["notifications"]{
                        let notification = Notification(json: n)
                        notification.courseName = course.name
                        course.notifications.append(notification)
                    }
                }
                completionHandler(error: error)
            }
        
    }
    
    
    
    func getSyllabus(course: TeacherCourse?=nil, completionHandler: ResponseMessageHandler){
        let course = course ?? TeacherCourse.currentCourse!
        if course.syllabus != nil{
            completionHandler(error: nil)
            return
        }
        else{
            TeacherAuthenticationHelper.defaultHelper.getResponsePOST(RequestType.GET_SYLLABUS, parameters: ["course_id": course.courseId]){
                (error, json) in
                if error == nil{
                    course.syllabus = Syllabus(json: json)
                }
                completionHandler(error: error)
            }
        }
    }
    
    
//    func getStudentIdsInCourse(course: TeacherCourse, completionHandler: ResponseMessageHandler){
//        let authHelper = TeacherAuthenticationHelper.defaultHelper
//        authHelper.getResponsePOST(RequestType.GET_STUDENTS_IN_COURES, postBody: ["course_id": course.courseId]){
//            (error, json) in
//            if error == nil{
//                for (_, studentId) in json["students"]{
//                    course.studentIds.append(studentId.stringValue)
//                }
//            }
//            completionHandler(error: error)
//        }
//    }
//    
    func getStudentsInCourse(course: TeacherCourse, completionHandler: ResponseMessageHandler){
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOST(RequestType.GET_STUDENTS_IN_COURES, parameters: ["course_id": course.courseId]){
            (error, json) in
            if error == nil{
                course.studentDict = [:]
                course.studentIds = []
                for (_, student_json) in json["students"]{
                    let s = Student(json: student_json)
                    course.studentIds.append(s.studentId)
                    course.studentDict[s.studentId] = s
                }
                course.studentIds.sortInPlace(<)
            }
            completionHandler(error: error)
        }
    }
//    func getCourseDetails(course: TeacherCourse, completionHandler: ResponseMessageHandler){
//        self.getSyllabus(TeacherCourse.currentCourse){
//            [unowned self]
//            error in
//            if error == nil{
//                self.getStudentsInCourse(course){
//                    error in
//                    completionHandler(error: error)
//                }
//            }
//        }
//
//    }
    
    
    
    
    func modifyNotificationInCourse(course: TeacherCourse, notification: Notification, completionHandler: ResponseMessageHandler){
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        var a = notification.toDict()
        a["course_id"] = course.courseId
     
        authHelper.getResponsePOST(RequestType.MODIFY_NOTIFICATION, parameters: a){
            (error, json) in
            completionHandler(error: error)
        }
    }
    
    func postNotificationInCourse(course: TeacherCourse, notification: Notification, completionHandler: ResponseMessageHandler){
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        var a = notification.toDict()
        a["course_id"] = course.courseId
 
        authHelper.getResponsePOST(RequestType.POST_NOTIFICATION, parameters: a){
            (error, json) in
            if error == nil{
                notification.notificationId = json["ntfc_id"].stringValue
                course.notifications.insert(notification, atIndex: 0)
            }
            completionHandler(error: error)
        }
    }
    
    func deleteNotificationInCourse(course: TeacherCourse, notification: Notification, completionHandler: ResponseMessageHandler){
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOST(RequestType.DELETE_NOTIFICATION, parameters: ["course_id": course.courseId, "ntfc_id": notification.notificationId]){
            (error, json) in
            completionHandler(error: error)
        }

    }
    
    
    
    func getStudent(studentId: String, course: TeacherCourse, completionHandler: ResponseMessageHandler){
        if course.studentDict[studentId] != nil{
            completionHandler(error: nil)
            return
        }
        let authHelper = TeacherAuthenticationHelper.defaultHelper
        authHelper.getResponsePOST(RequestType.GET_STUDENT, parameters: ["course_id": course.courseId, "student_id": studentId]){
            (error, json) in
            if error == nil{
                let student = Student(json: json["student"])
                course.studentDict[student.studentId] = student
            }
            completionHandler(error: error)
        }
    }
    
    
    
    func getAsksForLeave(course: TeacherCourse?=nil, completionHandler: ResponseMessageHandler) {
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.GET_ASKS_FOR_LEAVE, parameters: [:], course: course){
            error, json in
            course.asks = []
            if error == nil{
                for ask_dict in json["pending_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
                for ask_dict in json["approved_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
                for ask_dict in json["disapproved_asks"].arrayValue{
                    let ask = AskForLeave(json: ask_dict)
                    course.asks.append(ask)
                }
            }
            completionHandler(error: error)
            
        }
    }
    
    func getAttendanceListAuto(course: TeacherCourse?=nil, completionHandler: ResponseHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.GET_ATTENDANCE_LIST_AUTO, parameters: [:], course: course){
            [unowned self]
            error, json in
            if error == nil{
                self.attendanceList = AttendanceList()
                for student_id in json["students"]["absent"].arrayValue{
                    self.attendanceList.absentStudents.append(student_id.stringValue)
                }
                for (student_id, seat) in json["students"]["present"].dictionaryValue{
                    let seat = seat.stringValue
                    if seat == "刷脸"{
                        self.attendanceList.seatMap[student_id] = "刷脸"
                    }
                    else{
                        let s = seat.characters.split("_")
                        self.attendanceList.seatMap[student_id]="\(String(s[0]))排\(String(s[1]))列"
                    }
                    self.attendanceList.presentStudents.append(student_id)
                }
                for student_id in json["students"]["asked"].arrayValue{
                    self.attendanceList.askedStudents.append(student_id.stringValue)
                }
            }
            completionHandler(error: error, json: json)
        }
    }
    
    
    
    
    func getAttendanceList(course: TeacherCourse?=nil, weekNo: Int, dayNo: Int, periodNo: Int, completionHandler: ResponseMessageHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.GET_ATTENDANCE_LIST, parameters: ["week_no": weekNo, "period_no": periodNo, "day_no": dayNo], course: course){
            [unowned self]
            error, json in
            if error == nil{
                self.attendanceList = AttendanceList()
                for student_id in json["students"]["absent"].arrayValue{
                    self.attendanceList.absentStudents.append(student_id.stringValue)
                }
                for (student_id, seat) in json["students"]["present"].dictionaryValue{
                    let seat = seat.stringValue
                    if seat == "刷脸"{
                        self.attendanceList.seatMap[student_id] = "刷脸"
                    }
                    else{
                        let s = seat.characters.split("_")
                        self.attendanceList.seatMap[student_id]="\(String(s[0]))排\(String(s[1]))列"
                    }
                    
                    self.attendanceList.presentStudents.append(student_id)
                }
                for student_id in json["students"]["asked"].arrayValue{
                    self.attendanceList.askedStudents.append(student_id.stringValue)
                }
            }
            completionHandler(error: error)
        }
    }
    
    
    func approveAskForLeave(course: TeacherCourse?=nil, askForLeave: AskForLeave, completionHandler: ResponseMessageHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.APPROVE_ASK_FOR_LEAVE, parameters: ["ask_id": askForLeave.askId], course: course){
            error, json in
            if error == nil{
                askForLeave.status = .APPROVED
                askForLeave.viewdAt = json["viewed_at"].stringValue
            }
            completionHandler(error: error)
        }
    }
    func disapproveAskForLeave(course: TeacherCourse, askForLeave: AskForLeave, completionHandler: ResponseMessageHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.DISAPPROVE_ASK_FOR_LEAVE, parameters: ["ask_id": askForLeave.askId], course: course){
            error, json in
            if error == nil{
                askForLeave.status = .DISAPPROVED
                askForLeave.viewdAt = json["viewed_at"].stringValue
            }
            completionHandler(error: error)
        }
    }
    
    func getAbsenceStatistics(course: TeacherCourse?=nil, completionHandler: ResponseMessageHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponsePOSTWithCourse(RequestType.GET_ABSENCE_STATISTICS, parameters: [:], course: course){
            error, json in
            if error == nil{
                course.absenceList = []
                for (student_id, count) in json["statistics"]{
                    course.absenceList.append((student_id, count.intValue))
                }
                course.absenceListSorted = course.absenceList.sort({$0.1 > $1.1})
                
            }
            completionHandler(error: error)
        }
    }

    func getStudentAvatar(studentId: String, course: TeacherCourse?=nil, completionHandler: ResponseFileHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.getResponseGetFile(RequestType.GET_STUDENT_AVATAR, method: .POST, parameters: ["course_id": course.courseId, "student_id": studentId]){
            error, data in
            if let error = error{
                completionHandler(error: error, data: nil)
            }
            else{
                course.studentDict[studentId]?.avartar = UIImage(data: data)
                completionHandler(error: nil, data: data)
            }
        }
    }
    
    func getCourseCover(course: TeacherCourse, completionHandler: ResponseMessageHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        auth.getResponseGetFile(RequestType.GET_COVER, method: .POST, parameters: ["main_course_id": course.mainCourseId]){
            error, data in
            if error == nil{
                course.coverImage = UIImage(data: data)
            }
            completionHandler(error: error)
        }
    }
    
    func checkInWithFace(course: TeacherCourse?=nil, seat_token: String, studentId: String, photo: UIImage, completionHandler: ResponseHandler){
        let auth = TeacherAuthenticationHelper.defaultHelper
        let course = course ?? TeacherCourse.currentCourse!
        auth.postFile(RequestType.CHECK_IN_WITH_FACE, fileName: "face.jpg", fileType: .JPG, fileData: UIImageJPEGRepresentation(photo, 0.8)!, args: ["course_id": course.courseId, "student_id": studentId, "seat_token": seat_token]){
            error, json in
            completionHandler(error: error, json: json)
        }
    }

    
    
    static func drop(){
        _defaultHelper = nil
    }
    
}