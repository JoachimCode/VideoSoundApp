import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var recordingTimer: Timer?
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    
    @IBAction func pressedBackButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToMenu", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        
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
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No camera available")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Error setting up video input: \(error)")
            return
        }
        
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                    print("No microphone available")
                    return
                }

                do {
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    if captureSession.canAddInput(audioInput) {
                        captureSession.addInput(audioInput)
                    }
                } catch {
                    print("Error setting up audio input: \(error)")
                    return
                }

        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        guard let outputFileURL = getOutputFileURL() else {
                    // If there's no valid filename, print an error or show an alert
                    print("Please enter a valid filename before recording.")
                    showAlert(message: "Please enter a valid filename before recording.")
                    return
                }
        guard !videoOutput.isRecording else {
            print("Already recording")
            return
        }
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
                    sender.setTitle("Recording...", for: .normal)
                    
                    // Start a timer to stop recording after 10 seconds
                    recordingTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
    }
    
    @objc func stopRecording() {
            if videoOutput.isRecording {
                videoOutput.stopRecording()
                recordButton.setTitle("authenticate", for: .normal)
                recordingTimer?.invalidate()  // Invalidate the timer
            }
        }
    
    func getOutputFileURL() -> Optional<URL> {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            // Check if the user entered a title in the text field
            let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // If no title is provided, use the current date and time as the file name
            let fileName: String
            if let title = title, !title.isEmpty {
                fileName = title  // Use the user-provided title
            } else {
                return nil
            }

            // Create the full URL for the output file with .mov extension
            let outputFileURL = documentsDirectory.appendingPathComponent("\(fileName).mov")
            return outputFileURL
        }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error)")
        } else {
            print("Video saved successfully at \(outputFileURL)")
        }
    }
}
