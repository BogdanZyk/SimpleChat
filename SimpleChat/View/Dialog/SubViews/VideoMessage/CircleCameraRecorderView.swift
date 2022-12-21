//
//  CircleCameraRecorderView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.12.2022.
//

import SwiftUI
import AVKit

struct CircleCameraRecorderView: View {
    @Binding var show: Bool
    @StateObject private var cameraManager = CameraManager()
    var body: some View {
        ZStack{
            if let url = cameraManager.recordedURL{
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(width: getRect().width - 40)
                    .clipShape(Circle())
            }else{
                CameraPreviewView()
                    .frame(width: getRect().width - 40)
                    .clipShape(Circle())
            }
            
        }
        .allFrame()
        .environmentObject(cameraManager)
        .background(Material.ultraThinMaterial)
        .overlay(alignment: .bottomLeading) {
            changeCameraButton
                .padding()
        }
        .overlay(alignment: .topTrailing){
            closeButton
        }
    }
}

struct CircleCameraRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        CircleCameraRecorderView(show: .constant(true))
    }
}


extension CircleCameraRecorderView{
    private var changeCameraButton: some View{
        Button {

        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .imageScale(.large)
                .foregroundColor(.blue)
        }
    }
    private var closeButton: some View{
        Button {
            cameraManager.stopRecording()
            show.toggle()
        } label: {
            Image(systemName: "xmark")
                .padding()
        }
    }
}
