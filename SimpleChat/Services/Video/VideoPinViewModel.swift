//
//  VideoPinViewModel.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 23.12.2022.
//

import SwiftUI


final class VideoPinViewModel: ObservableObject{
    
    @Published var focusedVideoMessage: Message?
    @Published var isDissAppearMessage: Bool = false
    @Published var isPlay: Bool = false
    
    func remove(){
        withAnimation {
            focusedVideoMessage = nil
        }
    }
    
    func playOrStop(){
        withAnimation {
            isPlay = !isPlay
        }
    }
}



