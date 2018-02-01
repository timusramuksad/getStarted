//
//  EndExamViewController.swift
//  AssessmentApp
//
//  Created by Sumit K Das on 6/5/17.
//  Copyright © 2017 Sumit K Das. All rights reserved.
//

import Foundation
import UIKit


class EndExamViewControllerClass: UIViewController{
    //Declare view objects
    
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var wrongAnswersLabel: UILabel!
    @IBOutlet weak var skippedAnswersLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var dataJSON : AnyObject?
    
    
    @IBAction func quitExam(_ sender: Any) {
        //POST data & quit
        
    }
    
    @IBAction func retryExam(_ sender: Any) {
       //Post Data
        
        
        //Reset Values
         timer.invalidate()
         timeInSeconds = 0
         questionIndex = 1
         correctAnswers = []
         wrongAsnwers = []
         skippedAnswers = []
        assessmentIDArray = []
        let dir = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let fileurl =  dir.appendingPathComponent("Data.xml")
        if FileManager.default.fileExists(atPath: fileurl.path) {
            
        }
        
        //Return to start page
        let vc: ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartExamViewController") as! ViewController
        
        var toController: UIViewController = vc
        var fromController: UIViewController = self

        DispatchQueue.main.async {
            let vc: ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartExamViewController") as! ViewController
            self.present(vc, animated: true, completion: nil)

        }
    }
    
    @IBOutlet weak var quit: UIButton!
    override func viewDidLoad() {
  
        super.viewDidLoad()
       //Set View Objects
        
        timeInSeconds += 1
        if timeInSeconds > 60{
            if timeInSeconds > 3600 {
                hour =  Int(modf(Double(timeInSeconds)/Double(3600)).0)
                min = Int(modf(Double(timeInSeconds)/Double(60)).0)
                sec = timeInSeconds % 60
                print(hour,min,sec)
            }
            min = Int(modf(Double(timeInSeconds)/Double(60)).0)
            sec = timeInSeconds % 60
            print(hour,min,sec)
        }
        else{
            hour = 0
            min = 0
            sec = timeInSeconds
        }
        var hourString = String(format: "%02d", arguments: [hour])
        var minuteString = String(format: "%02d", arguments: [min])
        var secondString = String(format: "%02d", arguments: [sec])

            
        correctAnswerLabel.text = String(correctAnswers.count)
        wrongAnswersLabel.text = String(wrongAsnwers.count)
        skippedAnswersLabel.text = String(skippedAnswers.count)
        timeLabel.text = "\(hourString):\(minuteString):\(secondString)"
        print("Correct",correctAnswers,"Wrong",wrongAsnwers,"Skipped",skippedAnswers)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let postData = self.createPOSTData()
//        self.postTestData(postDataBody: postData)
//        MARK: Disable Postresults for now - to integrate later with a new server
    }
    func createPOSTData() -> Data{
        var assessmentIDs = assessmentIDArray
        
        var correctAns = NSMutableString()
        var wrongAns = NSMutableString()
        var skippedAns = NSMutableString()
//        var timeData = [hourString, minuteString, secondString]
        var timeString = "\(hourString):\(minuteString):\(secondString)"
        
        for i in 1..<(assessmentIDArray.count){
            print(i)
            if correctAnswers.contains(i){
                correctAns.append("<item><map><assessmentID>\(assessmentIDArray[i-1])</assessmentID></map></item>")
                print("correct:",i)
            }else if wrongAsnwers.contains(i){
                wrongAns.append("<item><map><assessmentID>\(assessmentIDArray[i-1])</assessmentID></map></item>")
                print("incorrect",i)
            }else if skippedAnswers.contains(i){
                skippedAns.append("<item><map><assessmentID>\(assessmentIDArray[i-1])</assessmentID></map></item>")
                print("skipped",i)
            }else{
                
            }
        }

        
        
        let xmlRequest = "<?xml version='1.0' encoding='utf-8' standalone = 'no'?><map><correct><list>\(correctAns)</list></correct><wrong><list>\(wrongAns)</list></wrong><skip><list>\(skippedAns)</list></skip></map>"
        print(xmlRequest)
       let requestXmlData = xmlRequest.data(using: String.Encoding.utf8)
    return requestXmlData!
    }
    
    func postTestData(postDataBody : Data) -> Void {
//        let parameters = [] as XMLData
        
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: "http://cogknit.getsandbox.com/submitAssessment")!)
        
        request.httpMethod = "POST"
        
                let progressHUD = ProgressViewClass(text: "Submitting data..")
                self.view.addSubview(progressHUD)
                self.view.isUserInteractionEnabled = false
        
        request.httpBody = postDataBody
        
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
    
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                                    progressHUD.removeFromSuperview()
                                    self.view.isUserInteractionEnabled = true
                                }
            
            do {
                var testResponse  = response as! HTTPURLResponse
                
                print(data,testResponse.statusCode)
                if testResponse.statusCode == 200{
                    print("Successfully uploaded data")
                    
                    ////Present alert for success
                    let alertController = UIAlertController(title: "Success", message: "Test results uploaded sucessfully", preferredStyle:.alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
                        //End Exam
                        
                    }
                    alertController.addAction(okButton)
                    self.present(alertController, animated: true, completion: nil)
                    
                    ////End
                }else{
                    let alertController = UIAlertController(title: "Failure", message: "Uploading data failed", preferredStyle:.alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
                        //End Exam
                    }
                    alertController.addAction(okButton)
                    self.present(alertController, animated: true, completion: nil)
                    print("Upload failed")
                }
                
            } catch let error {
                let alertController = UIAlertController(title: "Failure", message: "Uploading data failed", preferredStyle:.alert)
                let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
                    //End Exam
                }
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
                print("failure")
            }
        })
        task.resume()
    }
}

