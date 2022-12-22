//
//  CameraPreviewFrame.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.12.2022.
//

import SwiftUI

struct CameraPreviewFrame: UIViewRepresentable{

    @EnvironmentObject var cameraManager: CameraManager
    var size: CGSize
    var isRecord: Bool = false

    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        if let preview = cameraManager.preview, cameraManager.captureSession.isRunning, !cameraManager.output.isRecording{
            print("Update")
            preview.frame.size = size
            uiView.layer.addSublayer(preview)
        }
    }
}
