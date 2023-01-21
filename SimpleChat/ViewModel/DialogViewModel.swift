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
    @Published var messageForAction: SelectedMessage?
    @Published var targetMessage: Message?
    @Published var highlightMessage: Message?
    @Published var isLoad: Bool = false
    @Published var isShowFirstMessage: Bool = false
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
         self.messages.append(message)
         self.text = ""
         self.targetMessage = message
     }
    
    func sendVoice(audio: MessageAudio) {
        let message = Message(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .voice, audio: audio)
            self.messages.append(message)
            self.targetMessage = message
     }
    
    func sendVideo(video: MessageVideo){
        let message = Message(id: UUID(), text: "", userId: "1", reciepType: .sent, contentType: .video, video: video)
        self.messages.append(message)
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
                 let message = Mocks.mockMassage
                 
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

extension DialogViewModel{
    
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
        }
    }
    
}

//MARK: - Replay and edit action
extension DialogViewModel{
    
    func onSetActionMessage(_ message: SelectedMessage){
        withAnimation(.easeInOut(duration: 0.15)) {
            messageForAction = message
        }
    }
}

//MARK: - Pin messsage

extension DialogViewModel{
    
    func pinMessage(_ message: Message){
        withAnimation(.easeInOut(duration: 0.15)) {
            pinnedMessage = message
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
