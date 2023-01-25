//
//  Mocks.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import Foundation

class Mocks{
    
    
    static var mockMassage: [Message] {
        var array = [Message]()
        
        (1...20).forEach { int in
            array.append(.init(id: UUID(), text: "\((1...1000).randomElement() ?? 1)", userId: "\((1...2).randomElement() ?? 1)", reciepType: .random))
        }
        
        return array
    }
    
    
    static let chat: Chat = .init(lastMessage: mockMassage.first!, userUnfo: .init(avatarURl: "", fullName: "Boris Aron"))
    
    
    static func fetchMocksChats() -> [ChatMockModel]{
        
        let users = [("Boris Aron", "awatar1"), ("Elena Gosh", "awatar3"), ("Erlan Yan", "awatar2"), ("Angela Hort", "awatar4"), ("Kim Ned", "awatar5"), ("Mika Worm", "awatar6")]
        
        let chats: [ChatMockModel] = users.map({
            .init(chat: .init(userUnfo: .init(avatarURl: $0.1, fullName: $0.0)), messages: Mocks.mockMassage)
        })
        
        return chats
    }
}
