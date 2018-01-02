//
//  DetailNoteViewController.swift
//  SimpleNotesApp
//
//  Created by Bukalapak on 7/25/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit

class DetailNoteViewController: UIViewController {
    
    var note: Note?
    var editedNote: Note?
    
    var index: Int!
    var isEdited: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let note = note {
            setUpUI(note: note)
        } else {
            note = Note(id: 0, title: "title", detail: "detail", date: getCurrentDate(), image: #imageLiteral(resourceName: "placeholder"))
            detailImageView.isHidden = true
        }
    }
    
    @IBAction func unwindFromEditNoteViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "saveNote" {
                if let note = editedNote {
                    isEdited = true
                    setUpUI(note: note)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "backFromDetailNote" {
                if let destination = segue.destination as? GridNoteViewController {
                    let index = destination.notes.index(of: note!)
                    if isEdited {
                        note = editedNote
                    }
                    destination.notes[index!] = note!
                }
            } else if identifier == "editFromDetailNote" {
                if let destination = segue.destination as? EditNoteViewController {
                    destination.note = note
                    destination.index = index
                }
            }
        }
    }
    
    private func setUpUI(note: Note) {
        titleLabel.text = note.title
        
        if note.detail == "" {
            detailLabel.isHidden = true
        } else {
            detailLabel.isHidden = false
            detailLabel.text = note.detail
        }
        
        if note.image == #imageLiteral(resourceName: "placeholder") {
            detailImageView.isHidden = true
        } else {
            detailImageView.isHidden = false
            detailImageView.image = note.image
        }
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: Date())
    }
}
