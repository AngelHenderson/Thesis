
//
//  MessageViewController.swift

//
//  Created by Angel Henderson on 1/31/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit

import Firebase
import FirebaseFirestore
import FirebaseDatabase
import SafariServices
import SwifterSwift
import Alamofire
import SwiftyJSON
import Firebase

import EmptyStateKit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var navigationView: NavigationView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton?
    lazy var bottomSheetPresentationManager = BottomSheetPresentationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNightMode()
        tableView.emptyState.delegate = self
        tableView.emptyState.dataSource = self
        
        navigationView?.titleLabel?.textColor = .primaryTextColor
        tableView?.backgroundColor = .primaryBackgroundColor
        self.view.backgroundColor = .primaryBackgroundColor
        
        checkButton?.onTap {
            self.markAllAsReadPage()
        }
        
        //NotificationCenter
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetCount"), object: nil)
        
        //Receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.databaseChanged(_:)), name: NSNotification.Name(rawValue: "messageCenterDatabaseChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayCurrentList), name: NSNotification.Name(rawValue: "resetList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupNightMode), name: NSNotification.Name(rawValue: "NightNightThemeChangeNotification"), object: nil)


        //Table Setup
        self.tableView.register(UINib(nibName: "MessageCenterTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageCenterTableViewCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60.0
        self.tableView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 115, right: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.markAllAsReadPageTapped), name: NSNotification.Name(rawValue: "markAllRead"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        trackScreen(name: "Message Center View")

        //.order(by: "timeStamp")
        Firestore.firestore().collection("messages").order(by: "timestamp", descending: true).getDocuments() { (document, err) in
            if let err = err {print("Error getting documents: \(err)")}
            else {
                messagesSnapshot = document!.documents
                updateMessageCenterKeys()
                self.displayCurrentList()
            }
        }

        checkButton?.setImageForAllStates(UIImage.ionicon(with: .iosCheckmarkOutline, textColor:.label, size: CGSize(width: 32, height: 32)))
    }
    
    @objc func setupNightMode() {
        var format = EmptyStateFormat()
        format.buttonWidth = 180
        format.verticalMargin = -40
        format.buttonWidth = 0
        format.backgroundColor = .primaryBackgroundColor
        format.titleAttributes = [.font: UIFont(name: "AvenirNext-DemiBold", size: 26)!, .foregroundColor: UIColor.label]
        format.descriptionAttributes  = [.font: UIFont(name: "Avenir Next", size: 14)!, .foregroundColor: UIColor.label]
        format.buttonColor = ColorKit.themeColor
        tableView.emptyState.format = format
    }
    
    func emptySetConfiguration(){
        tableView.emptyState.hide()
        
        if messageCenterKeysArray.isEmpty {
            tableView.emptyState.show(MessageState.noNotifications)
        }
    }
    
    // MARK: - Actions

    @objc func displayCurrentList() {
        getMessageCenterChangesFromiCloud()
        updateMessageCenterKeys()
        self.tableView.reloadData()
        emptySetConfiguration()
    }

    
    // MARK: - Notification Center
    
    @objc func databaseChanged(_ notification: NSNotification) {
        self.tableView.reloadData()
        emptySetConfiguration()
    }
    
    func openMessageUrl(_ notification: NSNotification) {
        if let sendUrl = notification.userInfo?["url"] as? String {
            let svc = SFSafariViewController(url: NSURL(string: sendUrl)! as URL)
            trackEvent(category: "MessageCenter", action: "MessageOpened", value: 1)
            parent?.present(svc, animated: true, completion: nil)
        }
    }
    
    
    func markAllAsReadPage() {
        let messageCenterMarkAllPrompt = MessageCenterMarkAllPrompt(nibName: "SingleChoiceWithImageViewController", bundle: nil)
        messageCenterMarkAllPrompt.titleString = "Mark All Messages as Read?"
        messageCenterMarkAllPrompt.subjectString = "Are you sure you would like to mark all messages as read?"
        messageCenterMarkAllPrompt.choiceImage = AppCoreKit.appIcon.cornerRadiusImage()
        messageCenterMarkAllPrompt.firstButton?.backgroundColor = ColorKit.themeColor
        messageCenterMarkAllPrompt.firstButtonString = "Yes"
        messageCenterMarkAllPrompt.cancelButtonString = "Cancel"
        print("Mark All Prompt")

        messageCenterMarkAllPrompt.transitioningDelegate = bottomSheetPresentationManager
        messageCenterMarkAllPrompt.modalPresentationStyle = .custom
        CommonKit.getCurrentViewController()?.present(messageCenterMarkAllPrompt, animated: true, completion: nil)
    }
    
    @objc func markAllAsReadPageTapped() {
        trackEvent(category: "Clear Messages", value: 1)
        for document in messagesSnapshot {messageReadFromMessageCenter(key: (document?.documentID)!)}
        self.tableView.reloadData()
        emptySetConfiguration()
        trackEvent(category: "MessageCenter", action: "MarkedAllAsRead", value: 1)
        showTempAlert(title: "Messages Cleared", subtitle: "Your messages have all been marked as read.")
    }
    
    
    // MARK: - Memory Warning

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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


extension MessageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specificKey = messageCenterKeysArray[indexPath.row]
        
        //Updates iCloud that message was read
        messageReadFromMessageCenter(key: specificKey)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetCount"), object: nil)
        
//        let document = messagesSnapshot[indexPath.row]
//
//        if (document?.documentID == specificKey) {
//            guard let title: String = document?.data()!["title"] as? String else {return}
//            guard let offerlink: String = document?.data()!["offerlink"] as? String else {return}
//            trackEvent(category: "Message Center", action: title, value: 1)
//            let svc = SFSafariViewController(url: NSURL(string: offerlink)! as URL)
//            present(svc, animated: true, completion: nil)
//        }
        
        for document in messagesSnapshot {
            if (document?.documentID == specificKey) {
                guard let title: String = document?.data()!["title"] as? String else {return}
                if let offerlink: String = document?.data()!["offerlink"] as? String {
                    trackEvent(category: "Message Center", action: title, value: 1)
                    let svc = SFSafariViewController(url: NSURL(string: offerlink)! as URL)
                    present(svc, animated: true, completion: nil)
                    return
                }
                
                if let deepLinkUrl: String = document?.data()!["deepLinkUrl"] as? String {
                    trackEvent(category: "Message Center", action: title, value: 1)
                    let svc = SFSafariViewController(url: NSURL(string: deepLinkUrl)! as URL)
                    present(svc, animated: true, completion: nil)
                    return
                }
                
                if let seoPath: String = document?.data()!["seoPath"] as? String {
                    trackEvent(category: "Message Center", action: title, value: 1)
                    let svc = SFSafariViewController(url: NSURL(string: seoPath)! as URL)
                    present(svc, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
}

extension MessageViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageCenterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageCenterTableViewCell", for: indexPath) as! MessageCenterTableViewCell
       
        //guard let document = messagesSnapshot[indexPath.row] else {return cell}
        
//        let documentID = document.documentID
        let specificKey = messageCenterKeysArray[indexPath.row]
        cell.buttonView?.alpha = messageCenterReadArray.contains(specificKey) == true ? 0 : 1
        cell.buttonView?.backgroundColor = ColorKit.themeColor
        
//        let document = messagesSnapshot[indexPath.row]
//        if (document?.documentID == specificKey) {
//            guard let title: String = document?.data()!["title"] as? String else {return cell}
//            guard let date: String = document?.data()!["date"] as? String else {return cell}
//            cell.titleLabel?.text = title
//            cell.subtitleLabel?.text = date
//        }
        
        
        for document in messagesSnapshot {
            if (document?.documentID == specificKey) {
                guard let title: String = document?.data()!["title"] as? String else {return cell}
                guard let date: String = document?.data()!["date"] as? String else {return cell}
                cell.titleLabel?.text = title
                cell.subtitleLabel?.text = date
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCenterKeysArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let specificKey = messageCenterKeysArray[editActionsForRowAt.row]

        let unread = UITableViewRowAction(style: .normal, title: "Mark as Unread") { action, index in
            messageMarkedAsUnreadFromMessageCenter(key: specificKey)
        }
        unread.backgroundColor = .orange
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            messageDeletedFromMessageCenter(key: specificKey)
        }
        delete.backgroundColor = .red
        
        let read = UITableViewRowAction(style: .normal, title: "Mark as Read") { action, index in
            //let specificKey = messageCenterKeysArray[index.row]
            messageReadFromMessageCenter(key: specificKey)
        }
        read.backgroundColor = #colorLiteral(red: 0.2796578407, green: 0.5634605289, blue: 0.9949753881, alpha: 1)

        
        if messageCenterReadArray.contains(specificKey) {
            return [delete, unread]
        }
        else {
            return [delete, read]

        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        let specificKey = messageCenterKeysArray[indexPath.row]

        let unread = UIContextualAction(style: .normal, title:  "Mark as Unread", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            messageMarkedAsUnreadFromMessageCenter(key: specificKey)
            success(true)
        })
        unread.backgroundColor = .orange
        
        let delete = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            messageDeletedFromMessageCenter(key: specificKey)
            success(true)
        })
        delete.backgroundColor = .red
        
        let read = UIContextualAction(style: .normal, title:  "Mark as Read", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            messageReadFromMessageCenter(key: specificKey)
            success(true)
        })
        read.backgroundColor =  #colorLiteral(red: 0.2796578407, green: 0.5634605289, blue: 0.9949753881, alpha: 1)
        
        if messageCenterReadArray.contains(specificKey) {return UISwipeActionsConfiguration(actions: [delete,unread])}
        else {return UISwipeActionsConfiguration(actions: [delete,read])}
    }
    
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let readAction = UIContextualAction(style: .normal, title:  "Mark as Read", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            let specificKey = messageCenterKeysArray[indexPath.row]
//            messageReadFromMessageCenter(key: specificKey)
//            success(true)
//        })
//        readAction.backgroundColor =  #colorLiteral(red: 0.2796578407, green: 0.5634605289, blue: 0.9949753881, alpha: 1)
//
//        return UISwipeActionsConfiguration(actions: [readAction])
//    }

}


extension Array where Element: Equatable {
    
    func reorder(by preferredOrder: [Element]) -> [Element] {
        
        return self.sorted { (a, b) -> Bool in
            guard let first = preferredOrder.index(of: a) else {
                return false
            }
            
            guard let second = preferredOrder.index(of: b) else {
                return true
            }
            
            return first < second
        }
    }
}


extension MessageViewController: EmptyStateDelegate {
    
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        
    }
}

extension MessageViewController: EmptyStateDataSource {
    
    func imageForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> UIImage? {
        return UIImage(named: "Messages")
    }
    
    func titleForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        return "No messages"
    }
    
    func descriptionForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        return "Sorry, you don't have any message. Please come back later."
        
    }
    
    func titleButtonForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
        return "Come back later"
        
    }
}

enum MessageState: CustomState {

    case noNotifications
    
    var image: UIImage? {
        switch self {
        case .noNotifications: return UIImage(named: "Messages")
        }
    }
    
    var title: String? {
        switch self {
        case .noNotifications: return "No message notifications"
        }
    }
    
    var description: String? {
        switch self {
        case .noNotifications: return "Sorry, you don't have any message. Please come back later."
        }
    }
    
    var titleButton: String? {
        switch self {
        case .noNotifications: return "Come back later"
        }
    }
}
