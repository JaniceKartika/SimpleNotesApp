//
//  EditNoteViewController.swift
//  SimpleNotesApp
//
//  Created by Bukalapak on 7/14/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit

class EditNoteViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var overlay: UIView?
    
    var note: Note?
    var index: Int!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var detailField: UITextView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var cancelImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    // pick an image
    @IBAction func actionButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            editImageView.image = pickedImage
            showImageField()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailField.delegate = self
        imagePicker.delegate = self
        
        // set border for UITextView
        detailField.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8).cgColor
        detailField.layer.borderWidth = 0.5
        detailField.layer.cornerRadius = 5
        
        // set listener for cancelImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cancelImageView.isUserInteractionEnabled = true
        cancelImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if let note = note {
            title = "Edit"
            titleField.text = note.title
            
            if note.detail == "" {
                setPlaceholderForTextView(placeholder: "Note Detail", textView: detailField)
            } else {
                detailField.text = note.detail
                detailField.textColor = UIColor.black
            }
            
            if note.image == #imageLiteral(resourceName: "placeholder") {
                hideImageField()
            } else {
                showImageField()
                editImageView.image = note.image
            }
        } else {
            title = "New Note"
            note = Note(id: 0, title: "title", detail: "detail", date: getCurrentDate(), image: #imageLiteral(resourceName: "placeholder"))
            setPlaceholderForTextView(placeholder: "Note Detail", textView: detailField)
            hideImageField()
        }
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        editImageView.image = #imageLiteral(resourceName: "placeholder")
        hideImageField()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setPlaceholderForTextView(placeholder: "Note Detail", textView: textView)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveNote" {
            if index == -1 {   // creating note
                if areBothFieldsEmpty(titleField: titleField, detailField: detailField) {
                    showAlertWithSingleButton(title: "Error", message: "You cannot create note with empty title and content.")
                    return false
                } else if titleField.text == "" {
                    showAlertWithSingleButton(title: "Error", message: "You cannot create note with empty title.")
                    return false
                } else {
                    return true
                }
            } else {   // editing note
                if areBothFieldsEmpty(titleField: titleField, detailField: detailField) {
                    showAlertWithSingleButton(title: "Error", message: "You cannot save note with empty title and content.")
                    return false
                } else if titleField.text == "" {
                    showAlertWithSingleButton(title: "Error", message: "You cannot save note with empty title.")
                    return false
                } else {
                    return true
                }
            }
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "saveNote" {
                if index == -1 {
                    if let destination = segue.destination as? GridNoteViewController {
                        let size = destination.notes.count
                        
                        note?.id = size > 0 ? (destination.notes[size - 1].id + 1) : 0
                        note?.title = titleField.text!
                        note?.detail = detailField.textColor == UIColor.lightGray ? "" : detailField.text
                        note?.date = getCurrentDate()
                        note?.image = editImageView.image!
                        
                        destination.notes.append(note!)
                    }
                } else {
                    if let destination = segue.destination as? DetailNoteViewController {
                        note?.title = titleField.text!
                        note?.detail = detailField.textColor == UIColor.lightGray ? "" : detailField.text
                        note?.date = getCurrentDate()
                        note?.image = editImageView.image!
                        destination.editedNote = note
                    }
                }
            } else if identifier == "cancelEditNote" {
                if index == -1 {
                    print("cancel create note")
                } else {
                    print("cancel edit note")
                }
            }
        }
    }
    
    private func areBothFieldsEmpty(titleField: UITextField, detailField: UITextView) -> Bool {
        return titleField.text == "" && (detailField.text == "" || detailField.textColor == UIColor.lightGray)
    }
    
    private func setPlaceholderForTextView(placeholder: String, textView: UITextView) {
        textView.text = placeholder
        textView.textColor = UIColor.lightGray
    }
    
    private func showAlertWithSingleButton(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoading(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideLoading() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showImageField() {
        editImageView.isHidden = false
        cancelImageView.isHidden = false
    }
    
    private func hideImageField() {
        editImageView.isHidden = true
        cancelImageView.isHidden = true
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: Date())
    }
}
