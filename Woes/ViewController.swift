//
//  ViewController.swift
//  Woes
//
//  Created by Nicholas Arduini on 2017-03-28.
//  Copyright © 2017 Nicholas Arduini. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {
    
    var lastPoint = CGVector()
    var currentPoint = CGVector()
    var audioPlayer : AVAudioPlayer! = nil
    var woeTimer = Timer()
    var motionManager = CMMotionManager()
    var woeOn = false
    var level = 1
    var systemFont = CGFloat(60)
    var levelFont = CGFloat(120)
    let woeCountKey = "woeCount"
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    @IBOutlet weak var woeTypeSegControl: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var woeCountLabel: UILabel!
    @IBOutlet weak var disableScreenSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.statusBarStyle = .lightContent
        
        let buttonSize = UIScreen.main.bounds.width * 2/3
        startButton.bounds.size = CGSize(width: buttonSize, height: buttonSize)
        startButton.layer.cornerRadius = buttonSize/2
        startButton.layer.borderWidth = 12
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: systemFont)
        startButton.center = self.view.center
        woeTypeSegControl.layer.borderWidth = 4
        woeTypeSegControl.layer.borderColor = UIColor.white.cgColor
        woeTypeSegControl.layer.cornerRadius = 4
        let segRect = CGRect(origin: woeTypeSegControl.frame.origin, size: CGSize(width: woeTypeSegControl.frame.size.width, height: 80))
        var segFont : UIFont! = nil
        if(UIScreen.main.bounds.width <= 320){
           segFont = UIFont.boldSystemFont(ofSize: 18.0)
        } else {
           segFont = UIFont.boldSystemFont(ofSize: 22.0)
        }
        
        
        woeTypeSegControl.frame = segRect
        woeTypeSegControl.setTitleTextAttributes([NSFontAttributeName: segFont],
                                                for: .normal)
        //woeTypeSegControl.titleTextAttributes(for: UIControlState.)
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        if (motionManager.isAccelerometerAvailable) {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates()
        }
        
        updateWoeCount()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWoeCount() ->Int {
        return UserDefaults.standard.integer(forKey: woeCountKey)
    }
    
    @IBAction func woeTypeChanged(_ sender: Any) {
        woeOn = true
        woeStateChange()
    }
    
    @IBAction func startButton(_ sender: Any) {
        woeStateChange()
    }
    
    @IBAction func disableScreenSwitch(_ sender: Any) {
        if(disableScreenSwitch.isOn){
            woeTypeSegControl.isEnabled = false
            startButton.isEnabled = false
        } else {
            woeTypeSegControl.isEnabled = true
            startButton.isEnabled = true
        }
    }
    
    func woeStateChange(){
        if(woeOn){
            woeTimer.invalidate()
            startButton.setTitle("Start", for: UIControlState.normal)
            startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: systemFont)
            startButton.setImage(nil, for: UIControlState.normal)
            if(audioPlayer != nil){
                audioPlayer.pause()
            }
            woeOn = false
        } else {
            woeTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
            startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.levelFont)
            level = 1
            if(woeTypeSegControl.selectedSegmentIndex == 0){
                startButton.setTitle("", for: UIControlState.normal)
                animateImageIn()
            } else {
                startButton.setTitle("0", for: UIControlState.normal)
                animatelevelOutThenIn()
            }
            
            woeOn = true
        }
    }
    
    func updateWoeCount(){
        woeCountLabel.text = "Woe count: \(getWoeCount())"
    }
    
    func playAudio(audioFile: String) {
        do {
            if let bundle = Bundle.main.path(forResource: audioFile, ofType: "wav") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
                audioPlayer.prepareToPlay()
                audioPlayer.numberOfLoops = 0
                audioPlayer.play()
                UserDefaults.standard.set((getWoeCount() + 1), forKey: woeCountKey)
                updateWoeCount()
                
            }
        } catch {
            print(error)
        }
    }
    
    func updateTimer(){
        if let accelerometerData = motionManager.accelerometerData {
            currentPoint = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            movementActivated(lastPoint: lastPoint, currentPoint: currentPoint, movementCondition: 18.0)
            lastPoint = currentPoint
        }
    }
    
    func movementActivated(lastPoint: CGVector, currentPoint: CGVector, movementCondition: CGFloat){
        if(abs(currentPoint.dx - lastPoint.dx) > movementCondition && abs(currentPoint.dy - lastPoint.dy) > movementCondition){
            chooseAudioClip()
        }
    }
    
    func chooseAudioClip(){
        if(woeTypeSegControl.selectedSegmentIndex == 1){
            if(level == 6){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_6")
                    startButton.setTitle("6", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level = 1
                }
            } else if(level == 5){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_5")
                    startButton.setTitle("5", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level += 1
                }
            } else if(level == 4){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_4")
                    startButton.setTitle("4", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level += 1
                }
            } else if(level == 3){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_3")
                    startButton.setTitle("3", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level += 1
                }
            } else if(level == 2){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_2")
                    startButton.setTitle("2", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level += 1
                }
            } else if(level == 1){
                if(audioPlayer == nil || !audioPlayer.isPlaying){
                    playAudio(audioFile: "Woes_Level_1")
                    startButton.setTitle("1", for: UIControlState.normal)
                    animatelevelOutThenIn()
                    level += 1
                }
            }
            
        } else {
            startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: systemFont)
            if(audioPlayer == nil || !audioPlayer.isPlaying){
                level = 1
                playAudio(audioFile: "Woes_Level_4")
            }
        }
        
    }
    
    func animatelevelOutThenIn(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            if(self.woeTypeSegControl.selectedSegmentIndex == 0){
                self.animateImageIn()
            } else {
                self.animatelevelIn()
            }
            
        })
    }
    
    func animatelevelIn(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.levelFont)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func animateTitleOut(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func animateImageIn(){
        startButton.setImage(UIImage(named: "woeMan"), for: UIControlState.normal)
        startButton.imageView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.startButton.imageView?.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
}
