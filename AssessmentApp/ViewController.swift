//
//  ViewController.swift
//  AssessmentApp
//
//  Created by Sumit K Das on 6/4/17.
//  Copyright © 2017 Sumit K Das. All rights reserved.
//

import UIKit


//Global Var

var timer = Timer()
var isTimerRunning = false
var hourString = String()
var minuteString = String()
var secondString = String()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
 
    //**** View elements:

    @IBAction func startButtonTapped(_ sender: Any) {
        
        let progressHUD = ProgressViewClass(text: "Preparing for Test..")
        self.view.addSubview(progressHUD)
        self.view.isUserInteractionEnabled = false
//
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        

        
        let url = URL(string: "http://cogknit.getsandbox.com/getassessment");
        let request = NSMutableURLRequest(url: url!);
        
        request.httpMethod = "GET"
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (nsData, res, err) -> Void in
            if (err == nil){
                DispatchQueue.main.async {
                    progressHUD.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                }
                
                if nsData != nil {
                    do{
                        
//                        let responseData = try JSONSerialization.jsonObject(with: nsData!, options: .mutableContainers) as? [String: Any]
                        
                     if (res as! HTTPURLResponse).statusCode == 200 {
//
                        let dir = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
                            let fileurl =  dir.appendingPathComponent("Data.xml")
                        
                        
                                if FileManager.default.fileExists(atPath: fileurl.path) {
                                    if let fileHandle = try? FileHandle(forUpdating: fileurl) {
                                        try! nsData?.write(to: fileurl, options: Data.WritingOptions.atomic)  
                                    }
                                } else {
                                    try! nsData?.write(to: fileurl, options: Data.WritingOptions.atomic)
                                }
                        
                                //Navigate to next screen
                        DispatchQueue.main.async {
                                let vc: QuestionPageViewController = UIStoryboard(name: "QuestionPageViewController", bundle: nil).instantiateViewController(withIdentifier: "QuestionPageViewController") as! QuestionPageViewController
                                self.present(vc, animated: true, completion: nil)
                            self.runTimer()

                        }
                        
                        }
                        else{
                            //Error- URL not responding
                        }
                    }
                    catch{
                        print("No data")
                        //Error- URL not responding
                }
            }
            else{
            print("Error")
                    //Error- no data
            }
            } else{//Error
                DispatchQueue.main.async {
                    progressHUD.removeFromSuperview()
                    self.view.isUserInteractionEnabled = true
                }
            }
        })
        task.resume()
    }
    
    @IBOutlet weak var startButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    func updateTimer() {
        
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
         hourString = String(format: "%02d", arguments: [hour])
         minuteString = String(format: "%02d", arguments: [min])
         secondString = String(format: "%02d", arguments: [sec])
        print("Main Timer \(hourString):\(minuteString):\(secondString)")
    }

}

