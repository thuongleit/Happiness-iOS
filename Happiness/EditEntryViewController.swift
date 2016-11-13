//
//  EditEntryViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import CoreLocation

class EditEntryViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var feelingImageView: UIImageView!
    @IBOutlet weak var feelingSlider: UISlider!
    
    @IBOutlet weak var uploadImageButton: UIButton!

    let locationManager = CLLocationManager()
    
    var entry: Entry?
    
    var textViewPlaceholderText = "I'm grateful for..."
    
    // The view y right before keyboard is shown
    var topY: CGFloat = 0
    var keyboardHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for location permission
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Hide keyboard on tap outside of text fields
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditEntryViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Scroll up view on keyboard showing
        // TODO(cboo): Buggy, need to fix.
//        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Placeholder entry text
        textView.text = textViewPlaceholderText
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        
        // If editing an existing entry, show values of that entry.
        // Else create an entry with current date and current question.
        if entry == nil {
            entry = Entry()
        }
        if let date = entry?.createdDate {
            dateLabel.text = UIConstants.dateString(from: date)
        }
        if let question = entry?.question {
            questionLabel.text = question.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Action
    
    @IBAction func onSaveButton(_ sender: Any) {
        // Call HappinessService to save entry
        saveEntry()
    }
    
    func saveEntry() {
        let locationCoordinate: CLLocationCoordinate2D = locationManager.location!.coordinate
        print("locations = \(locationCoordinate.latitude) \(locationCoordinate.longitude)")
        
        var entryMedia: [UIImage] = []
        if uploadImageButton.image(for: .normal) != UIImage.init(named: "image_placeholder") {
            entryMedia.append(uploadImageButton.image(for: .normal)!)
        }
        
        HappinessService.sharedInstance.create(text: textView.text, images: entryMedia, happinessLevel: Int(feelingSlider.value), location: Location(name: locationTextField.text, latitude: Float(locationCoordinate.latitude), longitude: Float(locationCoordinate.longitude)), success: { (entry: Entry) in
            self.dismiss(animated: true, completion: {})
        }) { (error: Error) in
            let alertController = UIAlertController(title: "Error saving entry", message:
                "Happiness monster hugged our server just a little too hard...", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Delete entry", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                self.dismiss(animated: true, completion: {})
            }))
            alertController.addAction(UIAlertAction(title: "Try saving again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                self.saveEntry()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onUploadButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //cameraImageView.contentMode = .scaleAspectFit //3
        //cameraImageView.image = chosenImage //4
        uploadImageButton.imageView?.contentMode = .scaleAspectFit
        uploadImageButton.setImage(chosenImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (keyboardSize.height > 0) {
                keyboardHeight = keyboardSize.height
                if topY == 0 {
                    topY = self.view.frame.origin.y
                }
                if self.view.frame.origin.y != (topY - keyboardHeight) {
                    self.view.frame.origin.y = topY - keyboardHeight
                }
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height > 0 {
                if (self.view.frame.origin.y != topY) {
                    self.view.frame.origin.y = topY
                }
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
