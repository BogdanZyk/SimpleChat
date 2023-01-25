//
//  CircleCameraRecorderView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.12.2022.
//

import SwiftUI
import AVKit

struct CircleCameraRecorderView: View {
    @State private var showCamera: Bool = false
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
                if showCamera{
                    Circle()
                        .fill(Material.ultraThin)
                }
            }
            .frame(width: getRect().width - 40)
            .clipShape(Circle())
            .rotation3DEffect(.degrees(showCamera ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(showCamera ? 0.95 : 1)
            .onTapGesture {
                switchCamera()
            }
            Spacer()
        }
        .allFrame()
        .environmentObject(cameraManager)
        .background(Material.ultraThinMaterial)
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
            let video = MessageVideo(id: UUID().uuidString, url: url, duration: 0)
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
    
    private func switchCamera(){
        cameraManager.switchCameraAndStart{
            withAnimation(.easeIn(duration: 0.2)) {
                showCamera.toggle()
            }
            withAnimation(.easeIn(duration: 0.1).delay(0.1)){
                showCamera.toggle()
            }
        }
        
    }
}
