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
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var dialogVM: DialogViewModel
    var body: some View {
        VStack{
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
            Spacer()
        }
        .allFrame()
        .environmentObject(cameraManager)
        .background(Material.ultraThinMaterial)
        .overlay(alignment: .bottomLeading) {
            changeCameraButton
                .padding()
        }
        .onChange(of: cameraManager.captureSession.isRunning) { isRunning in
            print("isRunning", isRunning)
            if isRunning{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    cameraManager.startRecording()
                }
            }
        }
        .onChange(of: cameraManager.finalURL) { url in
            guard let url = url else {return}
            let video = MessageVideo(id: "1", url: url, duration: 0)
            withAnimation {
                cameraManager.showCameraView.toggle()
            }
            dialogVM.sendVideo(video: video)
        }
        .onDisappear{
            cameraManager.resetAll()
        }
    }
}

struct CircleCameraRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        CircleCameraRecorderView(show: .constant(true))
            .environmentObject(CameraManager())
            .environmentObject(DialogViewModel())
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
}
