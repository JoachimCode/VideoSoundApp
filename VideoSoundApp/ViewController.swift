//
//  ViewController.swift
//  VideoSoundApp
//
//  Created by Joachim Duong on 18/09/2024.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var CameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordVideoPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCamera", sender: self)
    }
    
    @IBAction func playSoundPressed(_ sender: UIButton) {
        playSound()
    }
    
    var audioPlayer: AVAudioPlayer?

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

  
    func playSound() {
        configureAudioSession()
     
        guard let soundURL = Bundle.main.url(forResource: "playsound", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            print("Playing sound")
        } catch {
            print("Error playing sound: \(error)")
        }
    }

}

