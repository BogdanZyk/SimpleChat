//
//  Audio.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 19.12.2022.
//

import SwiftUI

struct Audio: Identifiable{
    
    var id: String
    var url: URL
    var duration: Int
    var decibles: [Float]
    
    var remainingDuration: Int
    
    var soundSamples = [AudioPreviewModel]()
    
    init(id: String, url: URL, duration: Int, decibles: [Float], soundSamples: [AudioPreviewModel] = [AudioPreviewModel]()) {
        self.id = id
        self.url = url
        self.duration = duration
        self.remainingDuration = duration
        self.decibles = decibles
        self.soundSamples = decibles.map({.init(magnitude: $0)})
    }
    

}

extension Audio{
    mutating func setDefaultColor(){
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.white.opacity(0.5)
            return cur
        }
    }
    mutating func updateRemainingDuration(_ currentTime: Int){
        if self.remainingDuration > 0{
            self.remainingDuration = duration - currentTime
        }
    }
    
    mutating func resetRemainingDuration(){
        remainingDuration = duration
    }
}


struct AudioPreviewModel: Hashable {
    var magnitude: Float
    var color: Color = .white.opacity(0.5)
}
