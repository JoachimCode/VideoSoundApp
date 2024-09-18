import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var recordingTimer: Timer?
    var audioRecorder: AVAudioRecorder?
    
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var VolumeSlider: UISlider!
    @IBOutlet weak var VolumeLabel: UILabel!
    @IBOutlet weak var volumePrecentageLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func pressedBackButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToMenu", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height
                self.view.frame.origin.y = -keyboardHeight   // Move view up by half of keyboard height
            }
        }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0  // Reset view position
        }
    
    func configureAudioSessionForRecording() {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                try audioSession.setActive(true)
            } catch {
                print("Failed to set audio session category: \(error)")
            }
        }
    
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
            if audioRecorder == nil {
                startRecording()
                recordButton.setTitle("Recording...", for: .normal)
                // Start a timer to stop recording after 10 seconds
                recordingTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
            } else {
                stopRecording()
            }
        }
    
    func startRecording() {
            guard let outputFileURL = getOutputFileURL() else {
                print("Please enter a valid filename before recording.")
                showAlert(message: "Please enter a valid filename before recording.")
                return
            }
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                playSound()
                audioRecorder = try AVAudioRecorder(url: outputFileURL, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
                print("Started recording audio")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    
    @objc func stopRecording() {
           audioRecorder?.stop()
           audioRecorder = nil
           recordButton.setTitle("Record", for: .normal)
           recordingTimer?.invalidate()  // Invalidate the timer
           print("Stopped recording audio")
       }
    
    func getOutputFileURL() -> URL? {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let title = title, !title.isEmpty else {
                return nil
            }
            
            let outputFileURL = documentsDirectory.appendingPathComponent("\(title).m4a")  // Save as .m4a audio file
            return outputFileURL
        }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // AUDIO
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


extension AudioViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Audio recorded successfully")
        } else {
            print("Failed to record audio")
        }
    }
}
