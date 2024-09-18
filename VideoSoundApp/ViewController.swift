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
    @IBOutlet weak var AudioButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordVideoPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCamera", sender: self)
    }
    
    @IBAction func AudioPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAudio", sender: self)
    }
    
    
}

