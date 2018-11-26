//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Kush on 26/11/18.
//  Copyright © 2018 Pradip. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var buttonPlay: UIButton!
    
    var isPlay: Bool = false

    @IBAction func PlayPlauseClicked(_ sender: UIButton) {
        
        if isPlay {
            sender.setTitle("Pause", for: .normal)
            musicPlayer?.play()
        } else {
            sender.setTitle("Play", for: .normal)
            musicPlayer?.pause()
        }
        
        isPlay = !isPlay
    }
    
    @objc func trackChange() {
        
        if let duration = self.musicPlayer?.currentItem?.duration, duration.seconds > 0  {
            let durationSecond = CMTimeGetSeconds(duration)
            let value = Float64(slider.value) * durationSecond

            let seekTime = CMTime(value: Int64(value), timescale: 1)
            self.musicPlayer?.seek(to: seekTime, completionHandler: { (_) in
                
            })
            
        }
        
    }
    
    let progress : UIProgressView = {
        let pv = UIProgressView()
        pv.setProgress(0, animated: true)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.isUserInteractionEnabled = false
        pv.progressTintColor = UIColor.blue.withAlphaComponent(0.5)
        return pv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.addTarget(self, action: #selector(trackChange), for: .valueChanged)
        slider.minimumTrackTintColor = UIColor.blue
        
        setupView()
        setupMusic()
    }
    
    func setupView() {
        self.view.addSubview(progress)
        
        progress.leftAnchor.constraint(equalTo: slider.leftAnchor, constant: 0).isActive = true
        progress.rightAnchor.constraint(equalTo: slider.rightAnchor, constant: 0).isActive = true
        progress.bottomAnchor.constraint(equalTo: slider.topAnchor , constant: -30).isActive = true
        
    }
    

    var musicPlayer : AVPlayer?
    
    func setupMusic() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeDefault)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print("Error", err)
            return
        }
        
//        let urlString = "https://pagalworld3.org/14475/02%20Pal%20-%20Jalebi%20-%20Arijit%20Singh.mp3"
        
        let urlString = "https://pagalworld3.org/14475/variation/190K/02%20Pal%20-%20Jalebi%20-%20Arijit%20Singh.mp3"
        
        if let musicString = urlString.removingPercentEncoding, let mp3String = musicString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: mp3String) {
            
            
            musicPlayer = AVPlayer(url: url)
            musicPlayer?.automaticallyWaitsToMinimizeStalling = false
            musicPlayer?.allowsExternalPlayback = false
            
            musicPlayer?.play()
            
            let interval = CMTime(value: 1, timescale: 2)
            musicPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { (progressTime) in
                if let duration = self.musicPlayer?.currentItem?.duration, duration.seconds > 0  {
                    
                    let durationSecond = CMTimeGetSeconds(duration)
                    
                    let second = CMTimeGetSeconds(progressTime)

                    self.slider.value = Float(second / durationSecond)

                    let TotalSecond = Int(second)
                    
                    let currentTime = CMTimeGetSeconds(self.musicPlayer!.currentTime())
                    let secs = Int(currentTime)
                    print(NSString(format: "%02d:%02d", secs/60, secs%60) as String)
                    
                    
                    print("TotalSecond:" , String(format: "%02d:%02d", TotalSecond / 60, TotalSecond % 60))
                    
                    
                    if let range = self.musicPlayer?.currentItem?.loadedTimeRanges.first {
                        let timeRange = range as CMTimeRange
                        
                        let bufferState = CMTimeGetSeconds(timeRange.duration)
                        
                        let result: Float = Float(bufferState / durationSecond)
                        
                        print("Buffering Seconds: ", result * 100 , "%")
                        self.progress.setProgress(result, animated: true)
                    }
                    
                }
                
            })
            
            
        }
    }
    
    
    
    

}











