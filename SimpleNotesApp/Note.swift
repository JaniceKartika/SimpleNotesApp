//
//  Note.swift
//  SimpleNotesApp
//
//  Created by Bukalapak on 7/14/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit
import os.log

class Note: NSObject, NSCoding {
    
    var id: Int
    var title: String
    var detail: String
    var date: String
    var image: UIImage?
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("notes")
    
    struct PropertyKey {
        static let id = "id"
        static let title = "title"
        static let detail = "detail"
        static let date = "date"
        static let image = "image"
    }
    
    init?(id: Int, title: String, detail: String, date: String, image: UIImage?) {
        // The title must not be empty
        guard !title.isEmpty else {
            return nil
        }
        
        guard !date.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
        self.image = image
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(detail, forKey: PropertyKey.detail)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: PropertyKey.id)
        
        // The title is required. If we cannot decode a title string, the initializer should fail.
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the note's title.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because detail is an optional property of Note, just use conditional cast.
        let detail = aDecoder.decodeObject(forKey: PropertyKey.detail) as? String
        
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("Unable to decode the note's date.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        self.init(id: id, title: title, detail: detail!, date: date, image: image)
    }
}
