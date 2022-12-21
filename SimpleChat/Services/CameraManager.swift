//
//  CameraManager.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 20.12.2022.
//

import SwiftUI
import AVFoundation


final class CameraManager: NSObject, ObservableObject{

    @Published var alert: Bool = false
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var captureSession = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput()
    
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    

    
    
    func checkPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status{
                    self.setUp()
                }
            }
        case .denied:
            alert.toggle()
        default:
            break
        }
    }
    
    func setUp(){
        do{
            
            self.captureSession.beginConfiguration()
            let cameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: cameraPosition)
            let cameraInput = try AVCaptureDeviceInput(device: cameraDevice!)
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            
            if captureSession.canAddInput(cameraInput) && captureSession.canAddInput(audioInput){
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
            }

            if captureSession.canAddOutput(output){
                captureSession.addOutput(output)
            }
            
            
            captureSession.commitConfiguration()
//            let session = AVCaptureSession()
//            session.sessionPreset = .medium
//
//            guard
//                let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .front),
//                  let input = try? AVCaptureDeviceInput(device: device),
//                  session.canAddInput(input) else { return }
//
//            session.beginConfiguration()
//            session.addInput(input)
//            session.commitConfiguration()
//
//            let output = AVCaptureVideoDataOutput()
//            guard session.canAddOutput(output) else { return }
//            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.SimpleChat.CircleVideo"))
//            session.beginConfiguration()
//            session.addOutput(output)
//            session.commitConfiguration()
//
//            videoOutput = output
//            captureSession = session
//            print("setUp")
        }
        catch{
            print(error.localizedDescription)
        }
    }

}



extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate{
//
//
//    enum CaptureState {
//        case idle, start, capturing, end
//    }
//
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
//        let filename = UUID().uuidString
//        switch captureState {
//        case .start:
//            // Set up recorder
//
//            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
//            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
//            let settings = videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
//            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings) // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
//            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
//            input.expectsMediaDataInRealTime = true
//            input.transform = CGAffineTransform(rotationAngle: .pi/2)
//            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
//            if writer.canAdd(input) {
//                writer.add(input)
//            }
//            writer.startWriting()
//            writer.startSession(atSourceTime: .zero)
//            DispatchQueue.main.async {
//                self.assetWriter = writer
//                self.assetWriterInput = input
//                self.adpater = adapter
//                self.captureState = .capturing
//                self.time = timestamp
//            }
//
//        case .capturing:
//            if assetWriterInput?.isReadyForMoreMediaData == true {
//                let time = CMTime(seconds: timestamp - time, preferredTimescale: CMTimeScale(600))
//                adpater?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
//            }
//            break
//        case .end:
//            guard assetWriterInput?.isReadyForMoreMediaData == true, assetWriter!.status != .failed else { break }
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
//            assetWriterInput?.markAsFinished()
//            assetWriter?.finishWriting { [weak self] in
//                self?.captureState = .idle
//                self?.assetWriter = nil
//                self?.assetWriterInput = nil
//                DispatchQueue.main.async {
//                    print(url)
//                }
//            }
//        default:
//            break
//        }
//    }
}




struct CameraPreviewFrame: UIViewRepresentable{

    @EnvironmentObject var cameraManager: CameraManager
    var size: CGSize
    
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        cameraManager.preview = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        cameraManager.preview.frame.size = size
        cameraManager.preview.videoGravity = .resizeAspectFill
        cameraManager.captureSession.startRunning()

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}





struct VideoRecordingView: UIViewRepresentable {
    
    @Binding var timeLeft: Int
    @Binding var onComplete: Bool
    @Binding var recording: Bool
    
    func makeUIView(context: UIViewRepresentableContext<VideoRecordingView>) -> PreviewView {
        let recordingView = PreviewView()
                
        recordingView.onComplete = {
            self.onComplete = true
        }
        
        recordingView.onRecord = { timeLeft, totalShakes in
            self.timeLeft = timeLeft
            self.recording = true
        }
        
        return recordingView
    }
    
    func updateUIView(_ uiViewController: PreviewView, context: UIViewRepresentableContext<VideoRecordingView>) {
        
    }
}


struct RecordingView: View {
    @State private var timer = 5
    @State private var onComplete = false
    @State private var recording = false
    
    var body: some View {
        ZStack {
            VideoRecordingView(timeLeft: $timer, onComplete: $onComplete, recording: $recording)
            VStack {
                Button(action: {
                    self.recording.toggle()
                }, label: {
                    Text("Toggle Recording")
                })
                    .foregroundColor(.white)
                    .padding()
                Button(action: {
                    self.timer -= 1
                    print(self.timer)
                }, label: {
                    Text("Toggle timer")
                })
                    .foregroundColor(.white)
                    .padding()
                Button(action: {
                    self.onComplete.toggle()
                }, label: {
                    Text("Toggle completion")
                })
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
    
}


extension PreviewView: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        didFinishRecordingTo?(outputFileURL)
        print(outputFileURL)
        resetRecording()
    }
}

class PreviewView: UIView {
    private var captureSession: AVCaptureSession?
    private var shakeCountDown: Timer?
    let videoFileOutput = AVCaptureMovieFileOutput()
    var recordingDelegate: AVCaptureFileOutputRecordingDelegate!
    var recorded = 0
    var secondsToReachGoal = 60
    
    var onRecord: ((Int, Int)->())?
    var onReset: (() -> ())?
    var onComplete: (() -> ())?
    var didFinishRecordingTo: ((URL) -> ())?
    
    init() {
        super.init(frame: .zero)
        
        var allowedAccess = false
        let blocker = DispatchGroup()
        blocker.enter()
        AVCaptureDevice.requestAccess(for: .video) { flag in
            allowedAccess = flag
            blocker.leave()
        }
        blocker.wait()
        
        if !allowedAccess {
            print("!!! NO ACCESS TO CAMERA")
            return
        }
        
        // setup session
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .front)
        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
            print("!!! NO CAMERA DETECTED")
            return
        }
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
        self.captureSession = session
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let layer = layer as! AVCaptureVideoPreviewLayer
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        recordingDelegate = self
        startTimers()
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
            self.captureSession?.startRunning()
            self.startRecording()
        } else {
            self.captureSession?.stopRunning()
        }
    }
    
    private func onTimerFires(){
        print("🟢 RECORDING \(videoFileOutput.isRecording)")
        secondsToReachGoal -= 1
        recorded += 1
        onRecord?(secondsToReachGoal, recorded)
        if(secondsToReachGoal <= 0){
            stopRecording()
            shakeCountDown?.invalidate()
            shakeCountDown = nil
            onComplete?()
        }
    }
    
    func startTimers(){
        if shakeCountDown == nil {
            shakeCountDown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
    
    func startRecording(){
        captureSession?.addOutput(videoFileOutput)
        
        let filePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(UUID().uuidString).mov")

        videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate)
        
    }
    func resetRecording(){
        print("resetRecording")
        stopRecording()
        shakeCountDown?.invalidate()
        shakeCountDown = nil
        //removeFile()
    }
    
    func removeFile() {
        if let url = videoFileOutput.outputFileURL{
            do {
                try FileManager.default.removeItem(at: url)
                print("remove")
            } catch {
                print(error)
            }
        }
    }
    
    func stopRecording(){
        videoFileOutput.stopRecording()
        print("🔴 RECORDING \(videoFileOutput.isRecording)")
    }
}
