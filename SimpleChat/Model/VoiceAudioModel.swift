//
//  VoiceAudioModel.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct VoiceAudioModel: Identifiable{
    
    var id: String
    var url: URL
    var duration: Double
    var decibles: [Float]
    
    var remainingDuration: Double
    
    var soundSamples = [AudioSimpleModel]()
    
    init(id: String, url: URL, duration: Double, decibles: [Float], soundSamples: [AudioSimpleModel] = [AudioSimpleModel]()) {
        self.id = id
        self.url = url
        self.duration = duration
        self.remainingDuration = duration
        self.decibles = decibles
        self.soundSamples = decibles.map({.init(magnitude: $0)})
    }
    

}

extension VoiceAudioModel{
    mutating func setDefaultColor(){
        self.soundSamples = self.soundSamples.map { tmp -> AudioSimpleModel in
            var cur = tmp
            cur.color = Color.white.opacity(0.5)
            return cur
        }
    }
    mutating func updateRemainingDuration(_ currentTime: Double){
        if remainingDuration < duration {
            remainingDuration = duration - currentTime
        }
    }
    
    mutating func resetRemainingDuration(){
        remainingDuration = duration
    }
}


struct AudioSimpleModel: Hashable {
    var magnitude: Float
    var color: Color = .white.opacity(0.5)
}
