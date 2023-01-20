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
    
    
    init(){
        self.chats = fetchMocksChats()
    }
    
    
    
    func fetchMocksChats() -> [ChatMockModel]{
        
        let users = ["Boris Aron", "Elena Gosh", "Erlan Yan", "Angela Hort"]
        
        let chats: [ChatMockModel] = users.map({
            .init(chat: .init(userUnfo: .init(avatarURl: "", fullName: $0)), messages: Mocks.mockMassage)
        })
        
        return chats
    }
}


extension ChatViewModel{
    
    func pinAction(_ id: String){
        guard let index = chats.firstIndex(where: {$0.id == id}) else {return}
        withAnimation {
            chats[index].chat.isPinned.toggle()
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
    
    func muteAction(_ id: String){
        guard let index = chats.firstIndex(where: {$0.id == id}) else {return}
        withAnimation {
            chats[index].chat.isMute.toggle()
        }
    }
    
    
    
}

