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
    
}
