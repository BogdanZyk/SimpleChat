//
//  ContentView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var voiceManager = VoiceManager()
    var body: some View {
        DialogView()
            .preferredColorScheme(.light)
            .environmentObject(voiceManager)
            .environmentObject(audioManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
