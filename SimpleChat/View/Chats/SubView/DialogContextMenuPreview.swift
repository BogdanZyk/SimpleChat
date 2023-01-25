//
//  DialogContextMenuPreview.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct DialogContextMenuPreview: View {
    let namespace: Namespace.ID
    @StateObject private var videoPinVM = VideoPinViewModel()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var recordManager = RecordManager()
    @StateObject private var dialogVM: DialogViewModel
    let chat: ChatMockModel
    
    init(chat: ChatMockModel, namespace: Namespace.ID){
        self.chat = chat
        self._dialogVM = StateObject(wrappedValue: DialogViewModel(messages: chat.messages))
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack(alignment: .top){
            
            DialogBodyView(namespace: namespace, dialogVM: dialogVM, pinMessageTrigger: .constant(0), isDisabledMessage: true)
            header
        }
    }
}

struct DialogContextMenuPreview_Previews: PreviewProvider {
    static var previews: some View {
        DialogContextMenuPreview(chat: Mocks.fetchMocksChats().first!, namespace: Namespace().wrappedValue)
    }
}

extension DialogContextMenuPreview{
    private var header: some View{
        HStack{
            Spacer()
            UserAvatarView(image: chat.chat.userUnfo.avatarURl, size: 35)
        }
        .overlay(alignment: .center) {
            Text("User name")
                .font(.callout.bold())
        }
        .padding(5)
        .background(Material.bar)
    }
}
