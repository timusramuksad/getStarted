//
//  QuestionPageViewController.swift
//  AssessmentApp
//
//  Created by Sumit K Das on 6/4/17.
//  Copyright © 2017 Sumit K Das. All rights reserved.
//

import UIKit

//Global variables
var totalQuestions = Int()
var questionIndex : Int = 1
var timeInSeconds : Int = 0
var sec: Int = 0
var min : Int = 0
var hour : Int = 0
var correctAnswers = [Int]()
var wrongAsnwers = [Int]()
var skippedAnswers = [Int]()
var testAssessmentID = String()
var assessmentIDArray = [String]()

class QuestionPageViewController: UIViewController, XMLParserDelegate {

    //----*******----Declare Variables
    var submitTitle = NSAttributedString()
    var nextTitle = NSAttributedString()
    var quitExamTitle = NSAttributedString()
    var quitExamDesc = NSAttributedString()
    var correctAnswerMessage = NSAttributedString()
    var isChecked1 : Bool = false
    var isChecked2 : Bool = false
    var isChecked3 : Bool = false
    var isChecked4 : Bool = false
    var questionText : String = String()
    var option1 : String = String()
    var option2 : String = String()
    var option3 : String = String()
    var option4 : String = String()
    
    
    var answerSelected = String()
    
    //XML Variables
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = Dictionary<String, Any>()
    var element = NSString()
    var explanation = NSMutableString()
    var question = NSMutableString()
    var answerChoices = [String]()
    var correctAnswer = NSMutableString()
    var assessmentID = NSMutableString()
    
    var problemDicts = [[String:AnyObject]()]
    
    //Timer variables
    var localTimer = Timer()
    var timeTaken = [String:String]() as Dictionary
    
    
    //----*******----Declare View Outlets
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var questionBody: UILabel!
    @IBOutlet weak var answerChoice1: UILabel!
    @IBOutlet weak var answerChoice2: UILabel!
    @IBOutlet weak var answerChoice3: UILabel!
    @IBOutlet weak var answerchoice4: UILabel!
   
    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    

    override func viewDidLoad() {
        
        ///
        let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        
        
        let fileURL = url.appendingPathComponent("Data.xml")
        
        print(fileURL)
        do {
            let data = try Data(contentsOf: fileURL)
            let dataString = String(data: data, encoding: .utf8)
            var trimmedString = dataString?.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: NSCharacterSet.whitespaces)
            if let trimmedData = trimmedString?.data(using: String.Encoding.utf8){
                print(trimmedData)
                self.posts = []
                let parser = XMLParser(data: trimmedData)
                parser.delegate = self
                parser.parse()
            }
            
        } catch{
            //Error
        }
        ///
        
        totalQuestions = posts.count - 1
        self.submitTitle = NSAttributedString(string: "Submit", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: (15.0)), NSForegroundColorAttributeName: UIColor.black])
        self.quitExamTitle = NSAttributedString(string: "Quit exam?", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: (18.0)), NSForegroundColorAttributeName: UIColor.red])
        self.quitExamDesc = NSAttributedString(string: "Do you want to quit the exam", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: (15.0)), NSForegroundColorAttributeName: UIColor.red])
        
        self.nextTitle = NSAttributedString(string: "Next", attributes: [:])
        
        self.correctAnswerMessage = NSAttributedString(string: "Correct Answer!", attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15), NSForegroundColorAttributeName : UIColor.green])
        
        testAssessmentID = assessmentID as String
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func skipButtopnTapped(_ sender: Any) {
        
        if !(questionIndex < totalQuestions){
            //End of test
//            timer.invalidate()
            skippedAnswers.append(questionIndex)
            DispatchQueue.main.async {
                let vc: EndExamViewControllerClass = UIStoryboard(name: "EndExamViewController", bundle: nil).instantiateViewController(withIdentifier: "EndExamViewController") as! EndExamViewControllerClass
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            //Move to next question
            let alertController = UIAlertController(title: "Skip?", message: "", preferredStyle:.actionSheet)
            let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
               //
                let vc: QuestionPageViewController = UIStoryboard(name: "QuestionPageViewController", bundle: nil).instantiateViewController(withIdentifier: "QuestionPageViewController") as! QuestionPageViewController
                self.present(vc, animated: true, completion: nil)
                skippedAnswers.append(questionIndex)
                questionIndex += 1
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .default)  {(action) -> Void in
            }
            alertController.addAction(okButton)
            alertController.addAction(cancelButton)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    

    @IBAction func nextButtonTapped(_ sender: Any) {
        
        
        self.checkAnswer(index: questionIndex)
        
        if questionIndex > totalQuestions{
            //end of test
            print("Correct:", correctAnswers.count, "Incorrect:", wrongAsnwers.count, "Skipped:", skippedAnswers.count)
        }
        else{
            //move to next question
            questionIndex += 1
        }
        
    }
    
    
    @IBOutlet weak var timerLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        //Instantiate view elements
        
        nextButton.isUserInteractionEnabled = false
        self.updateContent(index: questionIndex)
        
        //Start Timer
//        self.runLocalTimer()

    }
    
    
    @IBAction func endButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: self.quitExamTitle.string, message: self.quitExamDesc.string, preferredStyle:.actionSheet)
        let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
            //End Exam
            
            //Append all remaining questions to skipped
            for i in questionIndex..<(totalQuestions + 1){
                skippedAnswers.append(i)
            }
            
            DispatchQueue.main.async {
                let vc: EndExamViewControllerClass = UIStoryboard(name: "EndExamViewController", bundle: nil).instantiateViewController(withIdentifier: "EndExamViewController") as! EndExamViewControllerClass
                self.present(vc, animated: true, completion: nil)
//                timer.invalidate()
            }
            }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default)  {(action) -> Void in
        }
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----*** Update content for screen ***----
   
    func updateContent(index: Int) -> Void{
        DispatchQueue.main.async {
            self.questionNumber.text = "\(questionIndex)/\(totalQuestions)"
            if questionIndex > totalQuestions {
               self.nextButton.setAttributedTitle(self.submitTitle, for: .normal)
            }
        }
        print(assessmentID,question,explanation,correctAnswer)
        
        let tempDict = posts[index - 1] as! NSDictionary
        question = (tempDict.value(forKey: "question") as! NSMutableString)
        answerChoices = (tempDict.value(forKey: "answerChoices") as! [String])
        answerChoices = answerChoices.filter { $0 != nil }
        correctAnswer = (tempDict.value(forKey: "correctAnswer") as! NSMutableString)
        correctAnswer.trimmingCharacters(in: NSCharacterSet.whitespaces)
        explanation = (tempDict.value(forKey: "explanation") as! NSMutableString)
        
        //----**** Update Views ****----
        questionBody.text = question as String
        answerChoice1.text = answerChoices[0]
        answerChoice2.text = answerChoices[1]
        answerChoice3.text = answerChoices[2]
        answerchoice4.text = answerChoices[3]

    }

   
    //----**** Ans choice Button actions*****
    
    @IBAction func choice1ButtonTapped(_ sender: UIButton) {
        print("CB1")
        
        if isChecked1 == false{
            isChecked1 = true
            sender.setBackgroundImage(UIImage(named:"checked-box.png"), for: .normal)
            answerSelected = answerChoices[0]
            
            if isChecked2 == true{
                option2Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked2 = false
            }
            if isChecked3 == true{
                option3Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked3 = false
            }
            if isChecked4 == true{
                option4Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked4 = false
            }
            
        } else{
            isChecked1 = false
            sender.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
            answerSelected = ""
            
        }
        if (isChecked1||isChecked2||isChecked3||isChecked4){//enable nextButton
            self.nextButton.isUserInteractionEnabled = true
               self.nextButton.setTitleColor(UIColor.init(red: (10/255), green: (96/255), blue: (254/255), alpha: (1.0)), for: .normal)
                if questionIndex == (totalQuestions) {
                    self.nextButton.setAttributedTitle(self.submitTitle, for: .normal)
                    self.nextButton.setTitleColor(UIColor.black, for: .normal)
                }else{
//                    self.nextButton.setAttributedTitle(self.nextTitle, for: .normal)
                }
            
        }else{//Disable nextButton
                self.nextButton.isUserInteractionEnabled = false
                self.nextButton.setTitleColor(UIColor.gray, for: .normal)
                self.nextButton.tintColor = UIColor.gray
//                self.nextButton.setAttributedTitle(self.nextTitle, for: .normal)
            
        }
    }
    
    @IBAction func choice2ButtonTapped(_ sender: UIButton) {
        print("CB2")
        
        if isChecked2 == false{
            isChecked2 = true
            sender.setBackgroundImage(UIImage(named:"checked-box.png"), for: .normal)
            answerSelected = answerChoices[1]
            
            if isChecked1 == true{
                option1Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked1 = false
            }
            if isChecked3 == true{
                option3Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked3 = false
            }
            if isChecked4 == true{
                option4Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked4 = false
            }
            
        } else{
            isChecked2 = false
            sender.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
            answerSelected = ""
        }
        if (isChecked1||isChecked2||isChecked3||isChecked4){//enable nextButton
            self.nextButton.isUserInteractionEnabled = true
            if questionIndex == (totalQuestions) {
                self.nextButton.setAttributedTitle(self.submitTitle, for: .normal)
                self.nextButton.setTitleColor(UIColor.black, for: .normal)
            }else{
                self.nextButton.setTitleColor(UIColor.init(red: (10/255), green: (96/255), blue: (254/255), alpha: (1.0)), for: .normal)
            }

        }else{//Disable nextButton
            self.nextButton.isUserInteractionEnabled = false
            self.nextButton.setTitleColor(UIColor.gray, for: .normal)
//            self.nextButton.setAttributedTitle(nextTitle, for: .disabled)
        }
        
    }
    
    
    @IBAction func choice3ButtonTapped(_ sender: UIButton) {
        print("CB3")
        
        if isChecked3 == false{
            isChecked3 = true
            sender.setBackgroundImage(UIImage(named:"checked-box.png"), for: .normal)
            answerSelected = answerChoices[2]
            if isChecked1 == true{
                option1Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked1 = false
            }
            if isChecked2 == true{
                option2Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked2 = false
            }
            if isChecked4 == true{
                option4Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked4 = false
            }
            
        } else{
            isChecked3 = false
            sender.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
            answerSelected = ""
        }
        if (isChecked1||isChecked2||isChecked3||isChecked4){//enable nextButton
            self.nextButton.isUserInteractionEnabled = true
            if questionIndex == (totalQuestions){
                self.nextButton.setAttributedTitle(self.submitTitle, for: .normal)
                self.nextButton.setTitleColor(UIColor.black, for: .normal)
            }else{
                self.nextButton.setTitleColor(UIColor.init(red: (10/255), green: (96/255), blue: (254/255), alpha: (1.0)), for: .normal)
            }

        }else{//Disable nextButton
            self.nextButton.isUserInteractionEnabled = false
            self.nextButton.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    
    @IBAction func option4ButtonTapped(_ sender: UIButton) {
        print("CB4")
       
        if isChecked4 == false{
            isChecked4 = true
            sender.setBackgroundImage(UIImage(named:"checked-box.png"), for: .normal)
            answerSelected = answerChoices[3]
            if isChecked1 == true{
                option1Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked1 = false
            }
            if isChecked2 == true{
                option2Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked2 = false
            }
            if isChecked3 == true{
                option3Button.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
                isChecked3 = false
            }
            
        } else{
            isChecked4 = false
            sender.setBackgroundImage(UIImage(named: "unchecked_checkbox.png"), for: .normal)
            answerSelected = ""
        }
        if (isChecked1||isChecked2||isChecked3||isChecked4){//enable nextButton
            self.nextButton.isUserInteractionEnabled = true
            if questionIndex == (totalQuestions) {
                self.nextButton.setAttributedTitle(self.submitTitle, for: .normal)
                self.nextButton.setTitleColor(UIColor.black, for: .normal)
            }else{
                self.nextButton.setTitleColor(UIColor.init(red: (10/255), green: (96/255), blue: (254/255), alpha: (1.0)), for: .normal)
            }

        }else{//Disable nextButton
            self.nextButton.isUserInteractionEnabled = false
            self.nextButton.setTitleColor(UIColor.gray, for: .normal)
        }
    }
   
    //--- *** Check answer ***----
    func checkAnswer(index: Int) -> Void {
       
        var isCorrect : Bool
        let tempAnswerSelected = answerSelected
        if tempAnswerSelected == String(correctAnswer.trimmingCharacters(in: NSCharacterSet.whitespaces)) {
            isCorrect = true
        }else{
            isCorrect = false
        }
        
        if isCorrect{
            let alertController = UIAlertController(title: correctAnswerMessage.string, message: explanation as String, preferredStyle:.alert)
            let okButton = UIAlertAction(title: "OK"  as String, style: .default)  {(action) -> Void in
                
                if totalQuestions < questionIndex{
                    //End test
//                    timer.invalidate()
                    DispatchQueue.main.async {
                        let vc: EndExamViewControllerClass = UIStoryboard(name: "EndExamViewController", bundle: nil).instantiateViewController(withIdentifier: "EndExamViewController") as! EndExamViewControllerClass
                        self.present(vc, animated: true, completion: nil)
                        correctAnswers.append(questionIndex - 1)
                    }
                    
                }else{
                    DispatchQueue.main.async {
                    let vc: QuestionPageViewController = UIStoryboard(name: "QuestionPageViewController", bundle: nil).instantiateViewController(withIdentifier: "QuestionPageViewController") as! QuestionPageViewController
                    self.present(vc, animated: true, completion: nil)
                    correctAnswers.append(questionIndex - 1)
                    
                    }
                }
                
            }
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            let alertController = UIAlertController(title: "Incorrect", message: explanation as String, preferredStyle:.alert)
            let okButton = UIAlertAction(title: "OK", style: .default)  {(action) -> Void in
                if totalQuestions < questionIndex {
                    //End Test
                    DispatchQueue.main.async {
                        wrongAsnwers.append(questionIndex-1)
                        let vc: EndExamViewControllerClass = UIStoryboard(name: "EndExamViewController", bundle: nil).instantiateViewController(withIdentifier: "EndExamViewController") as! EndExamViewControllerClass
                        self.present(vc, animated: true, completion: nil)
                        
                    }
//                    print(correctAnswers,wrongAsnwers,skippedAnswers)
                }else{
                    let vc: QuestionPageViewController = UIStoryboard(name: "QuestionPageViewController", bundle: nil).instantiateViewController(withIdentifier: "QuestionPageViewController") as! QuestionPageViewController
                    self.present(vc, animated: true, completion: nil)
                    wrongAsnwers.append(questionIndex-1)
                }
            }
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    
    //--*** XML Parsing functios ***---
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName as NSString
        if (elementName as NSString).isEqual(to: "map")
        {
            elements =  Dictionary<String, Any>()
            elements = [:]
            explanation = NSMutableString()
            explanation = ""
            question = NSMutableString()
            question = ""
            correctAnswer = ""
            assessmentID = ""
        }
        
        if (elementName as NSString).isEqual(to: "item"){
            elements = [:]
        }
        if (elementName as NSString).isEqual(to: "answerChoice"){
            answerChoices = []
        }

        print(question,explanation)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        var tempDict = NSDictionary()
        if element.isEqual(to: "map"){
            problemDicts.append(tempDict as! [String : AnyObject])
        }
        if element.isEqual(to: "explanation") {
            explanation.append(string)
        } else if element.isEqual(to: "question") {
            question.append(string)
        } else if element.isEqual(to: "correctAnswer"){
            correctAnswer.append(string)
        } else if element.isEqual(to: "assessmentID"){
            assessmentID.append(string)
//            if (string.trimmingCharacters(in: NSCharacterSet.whitespaces)) != ""{
//                assessmentIDArray.append(string)
//            }
        }
        else if element.isEqual(to: "item"){
            var trimmedString = string.trimmingCharacters(in: NSCharacterSet.whitespaces)
            if trimmedString != ""{
                answerChoices.append(trimmedString)
            }
            }
        
        print(question,explanation)
        print("Ans Choice", answerChoices)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqual(to: "map") {
            if !explanation.isEqual(nil) {
//                elements.setObject(explanation, forKey: "explanation" as NSCopying)
                elements["explanation"] = explanation
            }
            if !question.isEqual(nil) {
//                elements.setObject(question, forKey: "question" as NSCopying)
                elements["question"] = question
            }
            if !assessmentID.isEqual(nil) {
//                elements.setObject(assessmentID, forKey: "assessmentID" as NSCopying)
                elements["assessmentID"] = assessmentID
                if (assessmentID.trimmingCharacters(in: NSCharacterSet.whitespaces)) != ""{
                    let tempAssessmentID = assessmentID.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                    if !(assessmentIDArray.contains(tempAssessmentID)){ //Remove duplicates
                        assessmentIDArray.append(tempAssessmentID as String)
                    }
                }
            }
            if !correctAnswer.isEqual(nil) {
//                elements.setObject(correctAnswer, forKey: "correctAnswer" as NSCopying)
                elements["correctAnswer"] = correctAnswer
            }
            if !answerChoices.isEmpty{
//                elements.setObject(answerChoices, forKey: "answerChoices" as NSCopying)
                elements["answerChoices"] = answerChoices
            }
            posts.add(elements)
            print(posts, question, explanation)
        }
    }
    
    func runLocalTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateLocalTimer)), userInfo: nil, repeats: true)
    }
    
    func updateLocalTimer(){
        timerLabel.text = "\(hourString):\(minuteString):\(secondString)"
    }
}
