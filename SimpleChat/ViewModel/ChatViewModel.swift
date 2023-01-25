//
//  ChatViewModel.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

class ChatViewModel: ObservableObject{
    
    @Published var chats = [ChatMockModel]()
    
    @Published var arhivedChats = [ChatMockModel]()
    @Published var selectedChat: ChatMockModel?
    @Published var showChat: Bool = false
    
    init(){
        self.chats = Mocks.fetchMocksChats()
    }
    
}


extension ChatViewModel{
    
    func pinAction(_ chat: Binding<Chat>){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
            withAnimation {
                chat.isPinned.wrappedValue.toggle()
            }
        }
        
    }
    
    func deleteChat(_ id: String){
        withAnimation {
            chats.removeAll(where: {$0.id == id})
        }
    }
    
    func addArhived(_ id: String){
        guard let chat = chats.first(where: {$0.id == id}) else {return}
        withAnimation {
            arhivedChats.append(chat)
        }
        deleteChat(id)
    }
    
    func muteAction(_ chat: Binding<Chat>){
        withAnimation {
            chat.isMute.wrappedValue.toggle()
        }
    }
    
    
    
}

