//
//  ViewController.swift
//
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messages = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        messageTableView.separatorStyle = .none
        
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        let msg = messages[indexPath.row]
        cell.messageBody.text = msg.messageBody
        cell.senderUsername.text = msg.sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        let isSenderSelf = msg.sender == Auth.auth().currentUser?.email
        cell.avatarImageView.backgroundColor = isSenderSelf ? UIColor.flatMint() : UIColor.flatSkyBlue()
        cell.messageBackground.backgroundColor = isSenderSelf ? UIColor.flatGreen() : UIColor.flatBlue()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    //TODO: Declare textFieldDidBeginEditing here:
    
    
    //TODO: Declare textFieldDidEndEditing here:
    
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        sendButton.isEnabled = false
        
        let msgDB = Database.database().reference().child("Messages")
        let msgInfo = [
            "Sender": Auth.auth().currentUser?.email,
            "MessageBody": messageTextfield.text!
        ]
        
        msgDB.childByAutoId().setValue(msgInfo) { (err, ref) in
            if err != nil {
                print(err!)
            } else {
                print("Message sent!")
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                self.scrollToBottom()
            }
        }
    }
    
    func retrieveMessages() {
        let msgDB = Database.database().reference().child("Messages")
        msgDB.observe(.childAdded) { (snapshot) in
            let value = snapshot.value as! Dictionary<String, String>
            self.messages.append(Message(sender: value["Sender"]!, messageBody: value["MessageBody"]!))
            self.configureTableView()
            self.messageTableView.reloadData()
            self.scrollToBottom()
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Cannot sign out!")
        }
        guard navigationController?.popToRootViewController(animated: true) != nil else {
            print("No view controllers to pop off!")
            return
        }
    }
    
}
