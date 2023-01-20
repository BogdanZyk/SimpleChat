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
        
        let users = ["Boris", "Elena"]
        
        let chats: [ChatMockModel] = users.map({
            .init(chat: .init(userUnfo: .init(avatarURl: "", fullName: $0)), messages: Mocks.mockMassage)
        })
        
        return chats.sorted(by: {$0.chat.isMute && !$1.chat.isMute})
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
        withAnimation {
            let chat = chats.drop(while: {$0.id == id})
            arhivedChats.append(contentsOf: chat)
        }
    }
    
    func muteAction(_ id: String){
        guard let index = chats.firstIndex(where: {$0.id == id}) else {return}
        withAnimation {
            chats[index].chat.isMute.toggle()
        }
    }
    
    
    
}

