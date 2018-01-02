import Foundation
import UIKit

class Helper {
    
    class func handleEmptyMessage(message: String, tableView: UITableView, haveData: Bool) {
        if haveData {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = message
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel;
            tableView.separatorStyle = .none;
        }
    }
    
    class func handleEmptyMessage(message: String, collectionView: UICollectionView, haveData: Bool) {
        if haveData {
            collectionView.backgroundView = nil
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            messageLabel.text = message
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            messageLabel.sizeToFit()
            
            collectionView.backgroundView = messageLabel;
        }
    }
}
