//
//  EditEntryViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import CoreLocation
import ParseUI

class EditEntryViewController: ViewControllerBase, UIScrollViewDelegate, UITextViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var feelingImageView: UIImageView!
    @IBOutlet weak var feelingSlider: UISlider!
    
    @IBOutlet weak var uploadImageButton: UIButton!
    
    let locationManager = CLLocationManager()
    var placeOfInterest:String?
    
    var entry: Entry? {
        didSet {
            entryExisting = true
        }
    }
    // Whether this entry is already saved to the database. If true, update instead of create entry.
    var entryExisting: Bool = false
    
    var textViewPlaceholderText = "I'm grateful for..."
    
    // The view y right before keyboard is shown
    var topY: CGFloat = 0
    var keyboardHeight: CGFloat = 0
    
    deinit {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the navigation bar.
        if let navigationController = navigationController {
            
            // Set the navigation bar background color.
            navigationController.navigationBar.barTintColor = UIConstants.primaryThemeColor
            
            // Set the navigation bar text and icon color.
            navigationController.navigationBar.tintColor = UIConstants.textLightColor
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIConstants.textLightColor]
            
            // Set title.
            if entry == nil {
                navigationItem.title = "New Entry"
            } else {
                navigationItem.title = "Edit Entry"
            }
        }
        
        // Navigation bar save button.
        let saveButton = UIBarButtonItem(
            image: UIImage(named: UIConstants.ImageName.saveButton), style: .plain, target: self, action: #selector(EditEntryViewController.saveEntry))
        navigationItem.rightBarButtonItem = saveButton
        
        // Navigation bar cancel button.
        let cancelButton = UIBarButtonItem(
            image: UIImage(named: UIConstants.ImageName.cancelButton), style: .plain, target: self, action: #selector(EditEntryViewController.cancelEntry))
        navigationItem.leftBarButtonItem = cancelButton
        
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
        
        // Location Icon
        locationIconImageView.image = locationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        // Scroll up view on keyboard showing
        // TODO(cboo): Buggy, need to fix.
        //        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Style text view
        textView.layer.cornerRadius = 3.0
        textView.clipsToBounds = true
        
        // If new entry, use current date and current day's question.
        if entry == nil {
            dateLabel.text = UIConstants.dateString(from: Date())
            
            // Placeholder entry text
            textView.text = textViewPlaceholderText
            textView.textColor = UIColor.lightGray
            textView.delegate = self
        }
        // If editing an existing entry, show values of that entry.
        if let entry = entry {
            if let date = entry.createdDate {
                dateLabel.text = UIConstants.dateString(from: date)
            }
            if let text = entry.text {
                textView.text = text
            }
            if let locationName = entry.placemark {
                locationTextField.text = locationName
            }
            if let happinessLevel = entry.happinessLevel {
                feelingImageView.image = UIConstants.happinessLevelImage(happinessLevel)
                feelingSlider.value = Float(Entry.getHappinessLevelInt(happinessLevel: happinessLevel))
            }
            if let photoFile = entry.media {
                photoFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                    if error == nil {
                        let photo = UIImage(data: imageData!)
                        self.uploadImageButton.setImage(photo, for: .normal)
                    }
                })
            }
        }
        
        if let locationCoordinate = locationManager.location?.coordinate{
            
            placeOfInterest = UIConstants.getAddressForLatLng(latitude: Float(locationCoordinate.latitude), longitude: Float(locationCoordinate.longitude))
            locationTextField.placeholder = placeOfInterest
            //first show google maps state and city, and then try reverse geocoding to try apple maps for placemarks
            
            UIConstants.getAreaOfInterest(location: locationManager.location!, completion: {(areaOfInterest:String?, error: Error?) -> Void in
                if(error == nil) {
                    self.placeOfInterest = areaOfInterest
                    self.locationTextField.placeholder = self.placeOfInterest
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - HappinessService
    
    func cancelEntry() {
        self.dismiss(animated: true, completion: {})
    }
    
    func saveEntry() {
        
        // Dismiss the keyboard so that the animation is complete before any
        // congratulations confetti is displayed.
        dismissKeyboard()
        
        if (entryExisting) {
            updateEntry()
        } else {
            var entryMedia: [UIImage] = []
            if uploadImageButton.image(for: .normal) != UIImage.init(named: "camera") {
                entryMedia.append(uploadImageButton.image(for: .normal)!)
            }
            
            let locationCoordinate: CLLocationCoordinate2D = locationManager.location!.coordinate
            
            EntryBroker.shared.createEntry(
                text: textView.text,
                images: entryMedia,
                happinessLevel: Int(feelingSlider.value),
                placemark: placeOfInterest,
                location: Location(name: locationTextField.text, latitude: Float(locationCoordinate.latitude), longitude: Float(locationCoordinate.longitude)))
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Update existing entry that's already on database
    // TODO(cboo): Refactor out repetitive code.
    func updateEntry() {
        var entryMedia: [UIImage] = []
        if uploadImageButton.image(for: .normal) != UIImage.init(named: "image_placeholder") {
            entryMedia.append(uploadImageButton.image(for: .normal)!)
        }
        
        let locationCoordinate: CLLocationCoordinate2D = locationManager.location!.coordinate
        
        EntryBroker.shared.updateEntry(
            originalEntry: entry!,
            text: textView.text,
            images: entryMedia,
            happinessLevel: Int(feelingSlider.value),
            placemark: locationTextField.text,
            location: Location(name: locationTextField.text, latitude: Float(locationCoordinate.latitude), longitude: Float(locationCoordinate.longitude)))

        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - User Action
    @IBAction func onUploadButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        let optionMenu = UIAlertController(title: nil, message: "Please choose a photo source", preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        })
        let albumOption = UIAlertAction(title: "Photo Album", style: .default, handler: { (action) -> Void in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        optionMenu.addAction(cameraOption)
        optionMenu.addAction(albumOption)
        optionMenu.addAction(cancelOption)
        present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func onFeelingSliderChange(_ sender: UISlider) {
        let happinessLevelInt = Int(feelingSlider.value)
        let happinessLevel = Entry.getHappinessLevel(happinessLevelInt: happinessLevelInt)
        let feelingImage = UIConstants.happinessLevelImage(happinessLevel)
        if feelingImageView.image != feelingImage {
            UIView.transition(
                with: feelingImageView,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: { self.feelingImageView.image = feelingImage },
                completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //cameraImageView.contentMode = .scaleAspectFit //3
        //cameraImageView.image = chosenImage //4
        uploadImageButton.imageView?.contentMode = .scaleAspectFill
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
        if !entryExisting {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !entryExisting {
            if textView.text.isEmpty {
                textView.text = textViewPlaceholderText
                textView.textColor = UIColor.lightGray
            }
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
