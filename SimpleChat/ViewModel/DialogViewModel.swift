//
//  DialogViewModel.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import Foundation
import SwiftUI

final class DialodViewModel: ObservableObject{
    
    @Published var messages: [Message] = []
    @Published var selectedMessages = [Message]()
    @Published var text: String = ""
    @Published var targetMessage: Message?
    @Published var isLoad: Bool = false
    @Published var isShowFirstMessage: Bool = false
    @Published var dialogMode: DialogMode = .dialog
    
    init(){
        fetchMessages()
    }
}


enum DialogMode: Int{
    case messageSelecting, dialog, loading
}

extension DialodViewModel{
    
    func fetchMessages(){
        messages.append(contentsOf: mockMassage)
    }
    
    
    func send() {
         guard !text.isEmpty else { return }
         let message = Message(id: UUID(), text: self.text, userId: "1", type: .random)
         self.messages.append(message)
         self.text = ""
         self.targetMessage = message
     }
     
    func loadNextPageMessages(_ scrollView: ScrollViewProxy, message: Message){
         let lastMessageId = messages.first?.id
         let firstMessageId = messages.last?.id
         
         if firstMessageId == message.id{
             isShowFirstMessage = true
             print(message.text)
         }
         
         if lastMessageId == message.id && !isLoad && isShowFirstMessage {
             print(message.text)
             isLoad = true
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                 let message = mockMassage
                 
                 self.messages.insert(contentsOf: message, at: 0)
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                     scrollView.scrollTo(lastMessageId, anchor: .center)
                     self.isLoad = false
                 }
             }
         }
     }
    
}

//MARK: - Selecting message login

extension DialodViewModel{
    
    func isSelected(_ message: Message) -> Bool{
        selectedMessages.contains(message)
    }
    
    func selectMessage(_ message: Message){
        withAnimation(){
            if isSelected(message){
                selectedMessages.removeAll(where: {$0.id == message.id})
            }else{
                selectedMessages.append(message)
            }
        }
    }
}
