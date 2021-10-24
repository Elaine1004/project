//
//  ViewController.swift
//  歐伊喔伊 far away
//
//  Created by elaine on 2021/9/5.
//  Copyright © 2021 elaine. All rights reserved.
//
import UIKit
import MapKit
import AVFoundation
import CoreLocation

class ViewController:UIViewController,MKMapViewDelegate, AVAudioRecorderDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var MapView: MKMapView!  //地圖宣告
   //檔名按照數字命名
    var numOfRecorder: Int = 0
    let number : Int = 0
    var audioplayer : AVAudioPlayer!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var play: UIButton!
    var audioRecorder : AVAudioRecorder!  //宣告錄音
    var session : AVAudioSession!
    //AVAudioSession 是管理多個APP對音頻硬件設備（麥克風，揚聲器）的資源使用
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let lm = CLLocationManager()//定位
        MapView.delegate = self
               //追蹤使用者定位
        MapView.showsUserLocation = true //出現使用者位置
        MapView.userTrackingMode = .follow //追蹤使用者位置
        lm.desiredAccuracy = kCLLocationAccuracyBest //位置精準度
        lm.delegate = self
        lm.distanceFilter = kCLLocationAccuracyNearestTenMeters
        lm.desiredAccuracy = kCLLocationAccuracyBest;
        //允許存取使用者位置
        lm.requestAlwaysAuthorization()
        lm.requestWhenInUseAuthorization()
        //更新使用者位置
        lm.startUpdatingLocation()
        


          
      

             //
        let session = AVAudioSession.sharedInstance()
               do {
                   //設置音檔分類
                   try session.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                   try session.setActive(true)
                  // 檢查麥克風，是否有設備並跳出獲取權限通知
                   session.requestRecordPermission({ (isGranted: Bool) in
                       if isGranted {
                          //授與麥克風權限
                         var  appHasMicAccess = true
                       }
                       
                       else{
                          var appHasMicAccess = false
                       }
                   })
              } catch let error as NSError {
                   print("AVAudioSession configuration error: \(error.localizedDescription)")
               }
}
    
    
    func loadRecordingUI() {
       // record.isEnabled = true
           //play.isEnabled = false
          // record.setTitle("Record", for: .normal)
         
           view.addSubview(record)
        
       }
    //錄音設定
    func startRecording() {
            let audioFilename = getFileURL()
            //設置音檔格式
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2, //雙聲道
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self  //部分的責任能夠交給或委任給另一個實例化的class
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                
                record.setTitle("Stop", for: .normal)
              //  play.isEnabled = false
            } catch {
                finishRecording(success: false)
            }
        }
   
    @IBAction func play(_ sender: UIButton) {
    
   
        if (sender.titleLabel?.text == "play"){
       
        sender.setTitle("stop", for: .normal)
        preparePlayer()
        audioplayer.play()
        } else {
        audioplayer.stop()
        sender.setTitle("play", for: .normal)
        }
        }
        func preparePlayer() {
        var error: NSError?
        do {
        audioplayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
        error = error1
        audioplayer = nil
        }
        if let err = error {
        print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
        audioplayer.delegate = self
        audioplayer.prepareToPlay()
        audioplayer.volume = 10.0
        }
         
       }
        //結束錄音
         func finishRecording(success: Bool) {
             audioRecorder.stop()
             audioRecorder = nil
            record.setTitle("record", for: .normal)

            
             
            // play.isEnabled = true
            // record.isEnabled = true
         }
         
    
         
        //  儲存檔案位置
         func getDocumentsDirectory() -> URL {
             let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
             return paths[0]
         }
         //儲存檔案名稱
         func getFileURL() -> URL {
            var numOfRecorder: Int = 0

            if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
              numOfRecorder = number
            }
             let path = getDocumentsDirectory().appendingPathComponent("./\(numOfRecorder).wav")
             return path as URL
         }
         
         //MARK: Delegates
         
        //結束錄音
         func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
             if !flag {
                 finishRecording(success: false)
             }
         }
         //錄音有錯會顯示錯誤訊息
         func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
             print("Error while recording audio \(error!.localizedDescription)")
         }
         
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       //      record.isEnabled = true
       //   play.setTitle("play", for: .normal)
         }
         
         func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
                print("Error while playing audio \(error!.localizedDescription)")
         }
   
         
         
    
    
     
    @IBAction func record(_ sender: UIButton) {
        
      //如果錄音等於空值會開始錄音，否則結束錄音
        if audioRecorder == nil {
                    startRecording()
                } else {
                    finishRecording(success: true)
                }
        
        
      
   
    //api傳送到後端
    
    func sent (){
        var task: URLSessionDataTask!
        let url = URL(string: "http://0.0.0.0:5000")!
        var request1 = URLRequest(url: url,
                                  cachePolicy: .reloadRevalidatingCacheData)
        request1.httpMethod = "POST"
         task = URLSession.shared.dataTask(with: url) { data, response, error in
            if data != nil {
                var re = self.audioRecorder
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
           
       // request1.httpBody = "\(numOfRecorder).wav".data(using: )
        task.resume()
        
        

    }
    
    
    //api傳送到前端
    func get(date: String) {
      
      var request = URLRequest(url: URL(string: "http://0.0.0.0:5000/")!)
      request.httpMethod = "GET"
        //是一個請求的 HTTP 標頭，而 “content-type” 是鍵，”application/json” 就是所對應的值
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.setValue("\(numOfRecorder).wav", forHTTPHeaderField: "Content-Length")
      let session = URLSession.shared
      let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
          do {
              let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
              if let respond = json.values.first {
                  DispatchQueue.main.async {
                      let temp = respond as! String
                    let controller = UIAlertController(title: "警笛聲提醒", message: temp, preferredStyle: .alert)

                  }
              }
              
          } catch {
              print("error")
          }
      })
      
      task.resume()
  }
    
}

}
}
