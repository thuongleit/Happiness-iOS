//
//  EditEntryViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class EditEntryViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var feelingImageView: UIImageView!
    @IBOutlet weak var feelingSlider: UISlider!
    
    @IBOutlet weak var uploadImageButton: UIButton!

    var entry: Entry?
    
    var textViewPlaceholderText = "I'm grateful for..."
    
    // The view y right before keyboard is shown
    var topY: CGFloat = 0
    var keyboardHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide keyboard on tap outside of text fields
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditEntryViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Scroll up view on keyboard showing
        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditEntryViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Placeholder entry text
        textView.text = textViewPlaceholderText
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        
        // If editing an existing entry, show values of that entry.
        // Else create an entry with current date and current question.
        if entry == nil {
            entry = Entry.newEntry()
        }
        if let date = entry?.createdDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d y" // "EEE MMM d HH:mm:ss Z y"
            let dateString = formatter.string(from: date)
            dateLabel.text = dateString
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
