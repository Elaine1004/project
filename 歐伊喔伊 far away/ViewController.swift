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
  //  var numOfRecorder: Int = 0
   // var audioplayer : AVAudioPlayer! 測試音檔能不能播放
    @IBOutlet weak var record: UIButton!
   // @IBOutlet weak var play: UIButton!
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
        lm.distanceFilter =
          kCLLocationAccuracyNearestTenMeters
        lm.desiredAccuracy = kCLLocationAccuracyBest //位置精準度
        lm.delegate = self
        lm.distanceFilter = kCLLocationAccuracyNearestTenMeters
        lm.desiredAccuracy = kCLLocationAccuracyBest
        //允許存取使用者位置
      //  lm.requestAlwaysAuthorization()
        lm.requestWhenInUseAuthorization()
        //更新使用者位置
        lm.startUpdatingLocation()
       
        //當是Dark Mode時，會改變錄音按鈕的背景顏色及文字顏色
        if self.traitCollection.userInterfaceStyle == .dark {
            //為 Dark Mode 設定buttom為淺色
            record.backgroundColor = UIColor.white
            record.setTitleColor(UIColor.gray, for: .normal)
                   
               } else {
               }

     
      

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
    //開始錄音
    @objc func startRecording() {
            let audioFilename = getFileURL() //取得檔案位置
            //設置音檔格式
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1, //雙聲道無法傳給後端 //單聲道可以
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self  //部分的責任能夠交給或委任給另一個實例化的class
                audioRecorder.prepareToRecord()
                audioRecorder.record() //開始錄音
             
                
                record.setTitle("錄音中", for: .normal)//錄音開始設定錄音的字
              //  play.isEnabled = false
            } catch {
                finishRecording(success: false)
            }
        }
   //測試用
 /*   @IBAction func play(_ sender: UIButton) {
    
   
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
         
       }*/
    
   
        //結束錄音
    @objc func finishRecording(success: Bool) {
        
       
             audioRecorder.stop()
             audioRecorder = nil
             record.setTitle("錄音結束", for: .normal)
      
  

             
            // play.isEnabled = true
            // record.isEnabled = true
         }
         
    



   
         
        //  儲存檔案位置
         func getDocumentsDirectory() -> URL {
            let path = NSHomeDirectory() + "/Documents"
            let url  = URL(fileURLWithPath: path)
            return url
             
         }
         //儲存檔案名稱
         func getFileURL() -> URL {
             /*   var numOfRecorder: Int = 0
            if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
              numOfRecorder = number
            }
            let path =  getDocumentsDirectory().appendingPathComponent("test.wav")*/
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = urls[0] as URL
            let soundURL = documentDirectory.appendingPathComponent("recording.wav")
          
             return soundURL
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
        
      //如果錄音等於空值時會開始錄音，否則結束錄音
        if audioRecorder == nil {
            startRecording()
            
            } else {
                 //錄音結束
                finishRecording(success: true)
                
                do{ //api到後端 傳錄音檔
                let recordingData: Data? = try? Data(contentsOf: getFileURL() as URL)//取得資料
                let boundary = gBoundary() //
                let startBoundary = "--\(boundary)"
                let endingBoundary = "--\(boundary)--"
                    //http://ambulance.nutc.edu.tw:443/
                let url = URL(string: "http://0.0.0.0:5000/")
                var body = Data()//宣告資料
                let header = "Content-Disposition:form-data;name=audio;filename=recording.wav" //要傳給後端的檔名、名稱
                body.append(("\(startBoundary)\r\n" as String).data(using:.utf8)!)//Body加入資料
                body.append((header as String).data(using:.utf8)!) //檔案以utf-8編碼增加。
                body.append(("Content-Type: application/octet-stream\r\n\r\n" as String).data(using:.utf8)!)
                body.append(recordingData!)//加入錄音檔
                body.append(("\r\n\(endingBoundary)\r\n" as String).data(using:.utf8)!)

                var request = URLRequest(url: url!)
                request.httpMethod = "POST" //http request
                request.httpBody = body // 加入在網站的body裡
                request.setValue("multipart/form-data;boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
                request.setValue("application/json",forHTTPHeaderField: "Accept")
            

                let session = URLSession.shared//傳送http request的方式傳遞資料
                let task = session.dataTask(with: request){ (data, response,error) in
                            print("Upload complete!")

                            if let error = error{
                                  print("error: \(error)")
                                  return
                              }

                            guard let response = response as? HTTPURLResponse,
                                  (200...299).contains(response.statusCode) else {
                                      print("Error on server side!")
                                      return
                              }

                              if let mimeType = response.mimeType,
                              mimeType == "audio/wav",
                              let data = data,
                                  let dataStr = String(data: data, encoding: .utf8){
                                  print("data is \(dataStr)")
                              }
                  
                          }
                    task.resume()//用resume啟動 task
                    
                }
                
                get()
                      
                
            }
        func gBoundary() -> String{
            return "Boundary-\(NSUUID().uuidString)" //轉換編碼
        }
        
        
        //get獲得後端回傳值
        func get(){
            //列舉回傳值訊息
            enum type: String {
                   case A1 = "救護車逐漸遠離"
                   case A2 = "救護車逐漸靠近"
                   case B1 = "警車逐漸遠離"
                   case B2 = "警車逐漸靠近"
                   case C1 = "消防車逐漸遠離"
                   case C2 = "消防車逐漸靠近"
               }
            
        
        do  {
            //http://ambulance.nutc.edu.tw:443/
               let url = URL(string: "http://0.0.0.0:5000/")
               let value = try String(contentsOf: url!)
               //api 從後端取得回傳值。
               if value == "A1" {
                   let controller = UIAlertController(title: "提醒視窗", message: type.A1.rawValue, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                  return  present(controller, animated: true, completion: nil)

               }
               else if value == "A2" {
                   let controller = UIAlertController(title: "提醒視窗", message: type.A2.rawValue, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                   return present(controller, animated: true, completion: nil)
                   
               }
               else if value == "B1" {
                   let controller = UIAlertController(title: "提醒視窗", message: type.B1.rawValue, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                  return  present(controller, animated: true, completion: nil)
               
               }
               else if value == "B2" {
                   let controller = UIAlertController(title: "提醒視窗", message: type.B2.rawValue, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                 return   present(controller, animated: true, completion: nil)
               
               }
               else if value == "C1" {
                   let controller = UIAlertController(title: "提醒視窗", message: type.C1.rawValue ,preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                  return present(controller, animated: true, completion: nil)
              
               }
               else if value == "C2"{
                   let controller = UIAlertController(title: "提醒視窗", message: type.C2.rawValue, preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   controller.addAction(okAction)
                   return  present(controller, animated: true, completion: nil)
                   
               }
           }catch{ //印出錯誤
               print(error)
           }
                 
        }
        
        
        
}
}
 

   
    

