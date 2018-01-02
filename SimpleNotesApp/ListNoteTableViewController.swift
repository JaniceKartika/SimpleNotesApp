//
//  ListNoteTableViewController.swift
//  SimpleNotesApp
//
//  Created by Janice Kartika on 7/14/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit
import os.log

class ListNoteTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    
    enum SortKey: String {
        case title = "Title"
        case date = "Date"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = [SortKey.date.rawValue, SortKey.title.rawValue]
        searchController.searchBar.delegate = self
        
        if let savedNotes = loadNotes() {
            notes += savedNotes
            notes.sort(by: sortByDate)
        } else {
            loadSampleNote()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchBar.text!, scope: scope)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered() {
            return filteredNotes.count
        }
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        
        let note: Note
        if isFiltered() {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }
        
        cell.titleLabel.text = note.title
        cell.detailLabel.text = note.detail
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            if isFiltered() {
                notes.remove(at: notes.index(of: filteredNotes[indexPath.row])!)
                filteredNotes.remove(at: indexPath.row)
            } else {
                notes.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveNotes()
            
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltered() {
            Helper.handleEmptyMessage(message: "No results found.", tableView: tableView, haveData: filteredNotes.count > 0)
        } else {
            Helper.handleEmptyMessage(message: "No notes have been created.", tableView: tableView, haveData: notes.count > 0)
        }
        return 1
    }
    
    @IBAction func unwindToListNoteTableViewController(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "saveNote" {
                let searchBar = searchController.searchBar
                let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
                filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
                saveNotes()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editNoteViewController = segue.destination as! EditNoteViewController
        if let identifier = segue.identifier {
            if identifier == "editNote" {
                let index = tableView.indexPathForSelectedRow!.row
                if isFiltered() {
                    passDataToDetailNote(viewController: editNoteViewController, note: filteredNotes[index], index: index)
                } else {
                    passDataToDetailNote(viewController: editNoteViewController, note: notes[index], index: index)
                }
            } else if identifier == "createNote" {
                passDataToDetailNote(viewController: editNoteViewController, index: -1)
            }
        }
    }
    
    private func isFiltered() -> Bool {
        return searchController.isActive && searchController.searchBar.text != ""
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
        tableView.reloadData()
    }
    
    private func passDataToDetailNote(viewController: EditNoteViewController, note: Note? = nil, index: Int) {
        viewController.note = note
        viewController.index = index
    }
    
    private func saveNotes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notes, toFile: Note.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Notes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save notes.", log: OSLog.default, type: .error)
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
}
