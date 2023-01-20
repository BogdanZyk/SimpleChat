//
//  DialogContextMenuPreview.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.01.2023.
//

import SwiftUI

struct DialogContextMenuPreview: View {
    @StateObject private var videoPinVM = VideoPinViewModel()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var recordManager = RecordManager()
    @StateObject private var dialogVM: DialogViewModel
    
    init(messages: [Message]){
        self._dialogVM = StateObject(wrappedValue: DialogViewModel(messages: messages))
    }
    
    var body: some View {
        ZStack(alignment: .top){
            
            DialogBodyView(dialogVM: dialogVM, pinMessageTrigger: .constant(0), isDisabledMessage: true)
            header
        }
    }
}

struct DialogContextMenuPreview_Previews: PreviewProvider {
    static var previews: some View {
        DialogContextMenuPreview(messages: Mocks.mockMassage)
    }
}

extension DialogContextMenuPreview{
    private var header: some View{
        HStack{
            Spacer()
            Circle()
                .frame(width: 35, height: 35)
        }
        .overlay(alignment: .center) {
            Text("User name")
                .font(.callout.bold())
        }
        .padding(5)
        .background(Material.bar)
    }
}
