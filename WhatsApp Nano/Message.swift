//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

class Message {
    var sender = ""
    var messageBody = ""
    init(sender: String, messageBody: String) {
        self.sender = sender
        self.messageBody = messageBody
    }
}
