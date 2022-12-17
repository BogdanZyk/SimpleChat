//
//  ContentView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VoceViewTabComponent()
        //AudioPreviewView(audio: "https://muzati.net/music/0-0-1-20146-20")
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
