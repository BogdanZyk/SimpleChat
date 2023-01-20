//
//  ChatView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()
    @StateObject private var videoPinVM = VideoPinViewModel()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var recordManager = RecordManager()
    var body: some View {
        NavigationView {
            List{
                ForEach(chatVM.chats){chat in
                    NavigationLink {
                        DialogView(messages: chat.messages)
                            .environmentObject(audioManager)
                            .environmentObject(recordManager)
                            .environmentObject(cameraManager)
                            .environmentObject(videoPinVM)
                    } label: {
                        Text(chat.chat.userUnfo.fullName)
                    }
                }
            }
            .environmentObject(audioManager)
            .environmentObject(recordManager)
            .environmentObject(cameraManager)
            .environmentObject(videoPinVM)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
