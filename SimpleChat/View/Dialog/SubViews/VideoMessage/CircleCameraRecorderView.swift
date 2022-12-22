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
        VStack{
            Group{
                if let url = cameraManager.finalURL{
                    VideoPlayer(player: AVPlayer(url: url))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: getRect().width - 40)
                        .clipShape(Circle())
                }else{
                    ZStack{
                        Circle()
                            .fill(Material.ultraThin)
                        CameraPreviewView()
                        if cameraManager.output.isRecording{
                            CircleProgressBar(progress: cameraManager.recordedDuration, lineWidth: 4)
                                .frame(width: getRect().width - 60)
                                .zIndex(1)
                        }
                    }
                    .frame(width: getRect().width - 40)
                    .clipShape(Circle())
                }
                Spacer()
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
            HStack {
                closeButton
                Spacer()
                Button {
                    cameraManager.stopRecording(for: .user)
                } label: {
                    Text("Stop")
                }
                Spacer()
//                Button {
//                    
//                } label: {
//                    Text("Start")
//                }
            }
        }
        .onChange(of: cameraManager.isPermissions) { isPermissions in
            
            if isPermissions{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    cameraManager.startRecording()
                }
            }
        }
        .onChange(of: cameraManager.finalURL) { newValue in
            print(newValue)
        }
        .onDisappear{
            
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
            cameraManager.switchCameraAndStart()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .imageScale(.large)
                .foregroundColor(.blue)
        }
    }
    private var closeButton: some View{
        Button {
            
            show.toggle()
        } label: {
            Image(systemName: "xmark")
                .padding()
        }
    }
}
