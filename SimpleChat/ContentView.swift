//
//  ContentView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var recordManager = RecordManager()
    var body: some View {
        DialogView()
            .preferredColorScheme(.light)
            .environmentObject(audioManager)
            .environmentObject(recordManager)
            .environmentObject(cameraManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
