//
//  MessageAudio.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import Foundation
import SwiftUI

struct MessageAudio: Identifiable, Codable{
    var id: String
    var url: URL
    var duration: Int
    var decibles: [Float]
    
    
    func convertToVoiceAudioModel() -> VoiceAudioModel{
        .init(id: id, url: url, duration: duration, decibles: decibles)
    }
}
