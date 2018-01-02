//
//  NoteCollectionViewCell.swift
//  SimpleNotesApp
//
//  Created by Bukalapak on 7/24/17.
//  Copyright © 2017 JKM. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        detailLabel.text = nil
    }
}
