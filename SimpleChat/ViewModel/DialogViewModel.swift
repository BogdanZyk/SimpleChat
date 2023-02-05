//
//  DialogViewModel.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import Foundation
import SwiftUI

final class DialogViewModel: ObservableObject{
    
    @Published var messages: [Message] = []
    @Published var selectedMessages = [Message]()
    @Published var text: String = ""
    
    @Published var pinnedMessage: Message?
    @Published var toolbarMessage: SelectedMessage?
    @Published var targetMessage: Message?
    @Published var highlightMessage: Message?
    @Published var showHighlightMessage: Bool = false
    
    @Published var dialogMode: DialogMode = .dialog
    @Published var showCameraView: Bool = false
    
    
    init(messages: [Message]? = nil){
        guard let messages = messages else {return}
        self.messages.append(contentsOf: messages)
    }
}


enum DialogMode: Int{
    case messageSelecting, dialog, loading
}

extension DialogViewModel{
    
    
    func send() {
         guard !text.isEmpty else { return }
         let message = Message(id: UUID(), text: self.text, userId: "1", reciepType: .sent)
        self.messages.insert(message, at: 0)
         self.text = ""
         self.targetMessage = message
     }
    
    func sendVoice(audio: MessageAudio) {
        let message = Message(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .voice, audio: audio)
            self.messages.insert(message, at: 0)
            self.targetMessage = message
     }
    
    func sendVideo(video: MessageVideo){
        let message = Message(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: video)
        self.messages.insert(message, at: 0)
        self.targetMessage = message
    }
     
    func loadNextPageMessages(message: Message){
        
        if messages.last?.id == message.id {
            print(message.text)
            let message = Mocks.mockMassage
            withAnimation {
                self.messages.append(contentsOf: message)
            }
        }
    }
    
}




//MARK: - Selecting message logic

extension DialogViewModel{
    
    func highlightMessageAction(_ message: Message?){
        withAnimation {
            highlightMessage = message != nil ? message : nil
            showHighlightMessage = message != nil
        }
    }
    
    func isSelected(_ message: Message) -> Bool{
        selectedMessages.contains(where: {message.id == $0.id})
    }
    
    func selectMessage(_ message: Message){
        withAnimation(){
            if isSelected(message){
                selectedMessages.removeAll(where: {$0.id == message.id})
            }else{
                selectedMessages.append(message)
            }
            dialogMode = .messageSelecting
        }
    }
    
    func onSetActionMessage(_ message: SelectedMessage){
        withAnimation(.easeInOut(duration: 0.15)) {
            toolbarMessage = message
        }
    }
    
    func pinMessage(_ message: Message){
        withAnimation(.easeInOut(duration: 0.15)) {
            pinnedMessage = message
        }
    }
    
    func messageContextAction(_ type: MessageContextActionType, _ message: Message){
        switch type {
        case .replay:
            onSetActionMessage(.init(message: message, mode: .reply))
        case .copy:
            print("copy")
        case .pin:
            pinMessage(message)
        case .forward:
            print("forward")
        case .remove:
            print("remove")
        case .select:
            selectMessage(message)
        }
    }
}


//MARK: - Reaction logic

extension DialogViewModel{
    
    func setReaction(_ reaction: String, messageId: UUID){
        guard let index = messages.firstIndex(where: {$0.id == messageId}) else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            withAnimation(.easeInOut(duration: 0.2)){
                self.messages[index].reaction = reaction
            }
        }
    }
}


struct SelectedMessage{
    
    var message: Message?
    var mode: MessageMode = .reply
    
    enum MessageMode{
        case reply, edit
        
        var image: String{
            switch self{
            case .reply: return "arrowshape.turn.up.left"
            case .edit: return "pencil"
            }
        }
        
        var title: String{
            switch self{
            case .reply: return "Reply user"
            case .edit: return  "Edit"
            }
        }
    }
}
