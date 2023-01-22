//
//  MessageContextAction.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.01.2023.
//

import Foundation


enum MessageContextActionType: Int, CaseIterable{
    case replay, copy, pin, forward, remove, select
    
    var image: String{
        switch self {
        case .replay: return "arrowshape.turn.up.backward"
        case .copy: return "doc.on.doc"
        case .pin: return "pin"
        case .forward: return "arrowshape.turn.up.right"
        case .remove: return "trash"
        case .select: return "checkmark.circle"
        }
    }
    
    var title: String{
        switch self {
        case .replay: return "Replay"
        case .copy: return "Copy"
        case .pin: return "Pin"
        case .forward: return "Forward"
        case .remove: return "Remove"
        case .select: return "Select"
        }
    }
}



