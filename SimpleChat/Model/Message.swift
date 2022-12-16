//
//  Message.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI


struct Message: Codable, Hashable, Identifiable {
    var id: UUID
    var text: String
    var userId: String
    var type: RecieptType
    var date: Date = Date()
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



var mockMassage: [Message] {
    var array = [Message]()
    
    (1...20).forEach { int in
        array.append(.init(id: UUID(), text: "\((1...1000).randomElement() ?? 1)", userId: "\((1...2).randomElement() ?? 1)", type: .random))
    }
    
    return array
}
