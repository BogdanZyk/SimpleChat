//
//  Chat.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import Foundation


struct Chat: Identifiable{
    var id: String = UUID().uuidString
    var lastMessage: Message?
    var userUnfo: UserChatInfo
    var isPinned: Bool = false
    var unreadCount: Int = 0
    var isMute: Bool = false
}

extension Chat{
    var lastMessageTitle: String{
        switch lastMessage?.contentType{
        case .voice: return "Voice message"
        case .onlyText, .textAndImage: return self.lastMessage?.text ?? ""
        case .image: return "Image"
        case .video: return "Video message"
        case .none: return ""
        }
    }
}


extension Chat{
    struct UserChatInfo{
        var id: String = UUID().uuidString
        var avatarURl: String
        var fullName: String
    }
}


//MARK: - For test not use this model for backend!

struct ChatMockModel: Identifiable{
    var id: String = UUID().uuidString
    var chat: Chat
    var messages: [Message]
    
    init(chat: Chat, messages: [Message]){
        self.chat = chat
        self.chat.id = self.id
        self.messages = messages
        self.chat.lastMessage = self.messages.last
    }
}
