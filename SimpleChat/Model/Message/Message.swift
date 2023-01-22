//
//  Message.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI


struct Message: Codable, Identifiable, Equatable {

    var id: UUID
    var text: String
    var userId: String
    var reciepType: RecieptType
    var date: Date = Date()
    var contentType: MessageContentType = .onlyText
    var audio: MessageAudio?
    var video: MessageVideo?
    var reaction: String?
}

extension Message{
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

enum MessageContentType: String, Codable{
    case voice = "VOICE"
    case onlyText = "ONLY_TEXT"
    case textAndImage = "TEXT_IMAGE"
    case image = "IMAGE"
    case video = "VIDEO"
    
    var typeTitle: String{
        switch self {
        case .voice: return "Voice message"
        case .onlyText: return "Text message"
        case .textAndImage: return "Text and Image"
        case .image: return "Image message"
        case .video: return "Video message"
        }
    }
}

enum RecieptType: Int, Codable, Equatable {
    case sent
    case received
}




extension RecieptType {

    var backgroundColor: Color {
        switch self {
        case .sent:
            return .green
        case .received:
            return Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        }
    }
    
    var textColor: Color {
        switch self {
        case .sent:
            return .white
        case .received:
            return .black
        }
    }
    
    static var random: RecieptType {
        let random = Int.random(in: 0...1)
        return RecieptType(rawValue: random) ?? .sent
    }
}







