//
//  GridNoteViewController.swift
//  SimpleNotesApp
//
//  Created by Janice Kartika on 7/24/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit
import os.log

class GridNoteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var createNoteButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var gridLayout: GridLayout = GridLayout(numberOfColumns: 1)
    var isGrid: Bool = false
    
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    
    enum SortKey: String {
        case title = "Title"
        case date = "Date"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        setUpBarButtons()
        
        searchBar.delegate = self
        searchBar.scopeButtonTitles = [SortKey.date.rawValue, SortKey.title.rawValue]
        definesPresentationContext = true
        
        if let savedNotes = loadNotes() {
            notes += savedNotes
            notes.sort(by: sortByDate)
        } else {
            loadSampleNote()
        }
        
        collectionView.dataSource = self
        collectionView.collectionViewLayout = gridLayout
        collectionView.reloadData()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        collectionView.addGestureRecognizer(longPress)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchText, scope: scope)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = true
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
        searchBar.setShowsCancelButton(false, animated: true)
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: "", scope: scope)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltered() {
            return filteredNotes.count
        }
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! NoteCollectionViewCell
        
        let note: Note
        if isFiltered() {
            note = filteredNotes[indexPath.item]
        } else {
            note = notes[indexPath.item]
        }
        
        cell.titleLabel.text = note.title
        cell.detailLabel.text = note.detail
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltered() {
            Helper.handleEmptyMessage(message: "No results found.", collectionView: collectionView, haveData: filteredNotes.count > 0)
        } else {
            Helper.handleEmptyMessage(message: "No notes have been created.", collectionView: collectionView, haveData: notes.count > 0)
        }
        return 1
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        gridLayout.invalidateLayout()
    }
    
    @IBAction func unwindToGridNoteViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "backFromDetailNote" {
                refreshNote()
            }
        }
    }
    
    @IBAction func unwindFromEditNoteViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "saveNote" {
                refreshNote()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "detailNote" {
                if let destination = segue.destination as? DetailNoteViewController {
                    let cell = sender as! UICollectionViewCell
                    let index = collectionView.indexPath(for: cell)?.item
                    if isFiltered() {
                        passDataToDetailNote(viewController: destination, note: filteredNotes[index!], index: index!)
                    } else {
                        passDataToDetailNote(viewController: destination, note: notes[index!], index: index!)
                    }
                }
            } else if identifier == "editFromGridNote" {
                if let destination = segue.destination as? EditNoteViewController {
                    passDataToEditNote(viewController: destination, index: -1)
                }
            }
        }
    }
    
    @IBAction func changeLayout() {
        if isGrid {
            // list layout
            isGrid = false
            gridLayout = GridLayout(numberOfColumns: 1)
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.setCollectionViewLayout(self.gridLayout, animated: true)
            })
        } else {
            // grid layout
            isGrid = true
            gridLayout = GridLayout(numberOfColumns: 2)
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.setCollectionViewLayout(self.gridLayout, animated: true)
            })
        }
        setUpBarButtons()
    }
    
    private func setUpBarButtons() {
        let layoutButton: UIBarButtonItem
        if isGrid {
            layoutButton = UIBarButtonItem(image: #imageLiteral(resourceName: "list"), style: .plain, target: self, action: #selector(changeLayout))
        } else {
            layoutButton = UIBarButtonItem(image: #imageLiteral(resourceName: "grid"), style: .plain, target: self, action: #selector(changeLayout))
        }
        navigationItem.rightBarButtonItems = [createNoteButton, layoutButton]
    }
    
    @objc private func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        
        let point = gestureReconizer.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        
        if let _indexPath = indexPath {
            showAlertWithTwoButtons(title: "Delete Note", message: "Note will be deleted if you choose \"Delete\". Are you sure?", positiveButtonLabel: "Delete", handler: { action in
                self.deleteNote(indexPath: _indexPath)
            })
        } else {
            os_log("Could not find index path.", log: OSLog.default, type: .error)
        }
    }
    
    private func deleteNote(indexPath: IndexPath) {
        let pos =  indexPath.item
        if isFiltered() {
            notes.remove(at: notes.index(of: filteredNotes[pos])!)
            filteredNotes.remove(at: pos)
        } else {
            notes.remove(at: pos)
        }
        saveNotes()
        
        collectionView.deleteItems(at: [indexPath])
        collectionView.reloadData()
    }
    
    private func refreshNote() {
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchBar.text!, scope: scope)
        saveNotes()
    }
    
    private func isFiltered() -> Bool {
        return searchBar.text != ""
    }
    
    private func filterContentForSearchText(searchText: String, scope: String = SortKey.date.rawValue) {
        if searchText != "" {
            filteredNotes = notes.filter { note in
                return note.title.lowercased().contains(searchText.lowercased())
            }
            if scope == SortKey.title.rawValue {
                filteredNotes.sort(by: sortByTitle)
            } else {
                filteredNotes.sort(by: sortByDate)
            }
        } else {
            if scope == SortKey.title.rawValue {
                notes.sort(by: sortByTitle)
            } else {
                notes.sort(by: sortByDate)
            }
        }
        collectionView.reloadData()
    }
    
    private func passDataToDetailNote(viewController: DetailNoteViewController, note: Note? = nil, index: Int) {
        viewController.note = note
        viewController.index = index
    }
    
    private func passDataToEditNote(viewController: EditNoteViewController, note: Note? = nil, index: Int) {
        viewController.note = note
        viewController.index = index
    }
    
    private func saveNotes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notes, toFile: Note.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Notes successfully saved.", log: .default, type: .debug)
        } else {
            os_log("Failed to save notes.", log: .default, type: .error)
        }
    }
    
    private func loadNotes() -> [Note]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Note.ArchiveURL.path) as? [Note]
    }
    
    private func loadSampleNote() {
        let note = Note(id: 0, title: "Note Title", detail: "Detail of this note.", date: getCurrentDate(), image: #imageLiteral(resourceName: "placeholder"))
        notes.append(note!)
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: Date())
    }
    
    private func sortByTitle(this: Note, that: Note) -> Bool {
        return this.title < that.title
    }
    
    private func sortByDate(this: Note, that: Note) -> Bool {
        return this.date > that.date
    }
    
    private func showAlertWithTwoButtons(title: String, message: String, positiveButtonLabel: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: positiveButtonLabel, style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
