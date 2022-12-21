//
//  CameraPreviewView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.12.2022.
//

import SwiftUI

struct CameraPreviewView: View {
    @EnvironmentObject var cameraManager: CameraManager
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            CameraPreviewFrame(size: size)
                .environmentObject(cameraManager)
        }
        .onAppear(perform: cameraManager.checkPermissions)
        .alert("Text please Enable camera Access", isPresented: $cameraManager.alert, actions: {})
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreviewView()
            .environmentObject(CameraManager())
    }
}





