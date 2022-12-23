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
    @Published var showCameraView: Bool = false
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var captureSession = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput()
    
    @Published var cameraPosition: AVCaptureDevice.Position = .front
    @Published var recordedDuration: CGFloat = .zero
    @Published var maxDuration: CGFloat = 60
    @Published var finalURL: URL?
    @Published var isPermissions: Bool = false
    
    private var recordsURl = [URL]()
    
    private var timer: Timer?
    
    private var stopInitiatorType: Initiator = .empty
    

    
    func checkPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUp()
            isPermissions = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status{
                    self.setUp()
                }
                self.isPermissions = status
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
            
            guard let cameraDevice = cameraWithPosition(position: .front),
                  let audioDevice = getAudioDevice() else {return}
            
            let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            
            
            if captureSession.canAddInput(cameraInput) && captureSession.canAddInput(audioInput){
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
            }

            if captureSession.canAddOutput(output){
                captureSession.addOutput(output)
            }
            
            captureSession.commitConfiguration()
            
            startCaptureSession()
    
        }
        catch{
            print(error.localizedDescription)
        }
    }
        
    func startRecording(){
        //MARK: - Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        startTimer()
    }
    
    func stopRecording(for initiator: Initiator){
        stopInitiatorType = initiator
        output.stopRecording()
    }
    
    func resetAll(){
        timer?.invalidate()
        timer = nil
        output.stopRecording()
        captureSession.stopRunning()
        preview = nil
        recordedDuration = .zero
        
    }
    
    

    

   private func startCaptureSession() {

        let group = DispatchGroup()

        if !captureSession.isRunning {

            group.enter()

            DispatchQueue.global(qos: .default).async {
                [weak self] in

                self?.captureSession.startRunning()
                group.leave()

                group.notify(queue: .main) {
                    self?.preview = AVCaptureVideoPreviewLayer(session: self!.captureSession)
                    self?.preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                }
            }
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTripleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTrueDepthCamera, .builtInDualWideCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }

    func getAudioDevice() -> AVCaptureDevice?{
        let audioDevice = AVCaptureDevice.default(for: .audio)
        return audioDevice
    }

    
    
}



extension CameraManager: AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error{
            print(error.localizedDescription)
            return
        }
        
        self.recordsURl.append(outputFileURL)
        print(stopInitiatorType.rawValue)
        
        if recordsURl.count != 0 && (stopInitiatorType == .user || stopInitiatorType == .auto){
            let assets = recordsURl.compactMap({AVURLAsset(url: $0)})
            mergeVideos(assets: assets) {[weak self] exporter in
                guard let self = self else {return}
                exporter.exportAsynchronously {
                    if exporter.status == .failed{
                        print(exporter.error?.localizedDescription ?? "Error Exporter failed")
                    }else{
                        if let finalURL = exporter.outputURL{
                            DispatchQueue.main.async {
                                self.finalURL = finalURL
                                self.stopInitiatorType = .empty
                                print("Finished merge url", finalURL)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //merge videos assets in one video with format .mp4
   private func mergeVideos(assets: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession) -> ()){
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {return}
        
        for asset in assets {
            do{
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: lastTime)
                if !asset.tracks(withMediaType: .audio).isEmpty{
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: lastTime)
                }
            }
            catch{
                print(error.localizedDescription)
            }
            
            lastTime = CMTimeAdd(lastTime, asset.duration)
        }
       
       guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset960x540) else {return}
       let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "\(Date()).mp4")
       exporter.outputFileType = .mp4
       exporter.outputURL = tempUrl
       exporter.videoComposition = prepairVideoComposition(videoTrack, lastTime: lastTime)
       completion(exporter)
    }
    
    // bringing back to original transform
    private func prepairVideoComposition(_ videoTrack: AVMutableCompositionTrack, lastTime: CMTime) -> AVMutableVideoComposition{
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        //transform video
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90 * (.pi / 180))
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instrictions = AVMutableVideoCompositionInstruction()
        instrictions.timeRange = CMTimeRange(start: .zero, end: lastTime)
        instrictions.layerInstructions = [layerInstructions]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = .init(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instrictions]
        //fps
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        return videoComposition
    }
    
}

//MARK: - Switch camera
extension CameraManager{
    
    
    func switchCameraAndStart(){
        stopRecording(for: .onSwitch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.switchCamera()
            self.startRecording()
        }
        
    }
    
   private func switchCamera() {
        guard let currDevicePos = (captureSession.inputs.first as? AVCaptureDeviceInput)?.device.position
        else { return }
        
        //Indicate that some changes will be made to the session
        captureSession.beginConfiguration()
        
        //Get new input
        guard let newCamera = cameraWithPosition(position: (currDevicePos == .back) ? .front : .back ),
              let newAudio = getAudioDevice()
        else {
            print("ERROR: Issue in cameraWithPosition() method")
            return
        }
        
        do {
            let aududioInput = try AVCaptureDeviceInput(device: newAudio)
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            
            //remove all inputs in inputs array!
            while captureSession.inputs.count > 0 {
                captureSession.removeInput(captureSession.inputs[0])
            }
            
            captureSession.addInput(newVideoInput)
            captureSession.addInput(aududioInput)
            
        } catch {
            print("Error creating capture device input: \(error.localizedDescription)")
        }
        
        //Commit all the configuration changes at once
        captureSession.commitConfiguration()
    }
}

//MARK: - Timer

extension CameraManager{
    
    private func onTimerFires(){
        
        if recordedDuration <= maxDuration && output.isRecording{
            print("🟢 RECORDING")
            recordedDuration += 1
        }
        if recordedDuration >= maxDuration && output.isRecording{
            print("Auto stop")
            stopRecording(for: .auto)
            timer?.invalidate()
            timer = nil
        }
    }

    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                self?.onTimerFires()
            }
        }
    }
}

extension CameraManager{
    enum Initiator: Int{
        case user, auto, onSwitch, empty
    }
}




//struct VideoRecordingView: UIViewRepresentable {
//
//    @Binding var timeLeft: Int
//    @Binding var onComplete: Bool
//    @Binding var recording: Bool
//
//    func makeUIView(context: UIViewRepresentableContext<VideoRecordingView>) -> PreviewView {
//        let recordingView = PreviewView()
//
//        recordingView.onComplete = {
//            self.onComplete = true
//        }
//
//        recordingView.onRecord = { timeLeft, totalShakes in
//            self.timeLeft = timeLeft
//            self.recording = true
//        }
//
//        return recordingView
//    }
//
//    func updateUIView(_ uiViewController: PreviewView, context: UIViewRepresentableContext<VideoRecordingView>) {
//
//    }
//}
//
//
//struct RecordingView: View {
//    @State private var timer = 5
//    @State private var onComplete = false
//    @State private var recording = false
//
//    var body: some View {
//        ZStack {
//            VideoRecordingView(timeLeft: $timer, onComplete: $onComplete, recording: $recording)
//            VStack {
//                Button(action: {
//                    self.recording.toggle()
//                }, label: {
//                    Text("Toggle Recording")
//                })
//                    .foregroundColor(.white)
//                    .padding()
//                Button(action: {
//                    self.timer -= 1
//                    print(self.timer)
//                }, label: {
//                    Text("Toggle timer")
//                })
//                    .foregroundColor(.white)
//                    .padding()
//                Button(action: {
//                    self.onComplete.toggle()
//                }, label: {
//                    Text("Toggle completion")
//                })
//                    .foregroundColor(.white)
//                    .padding()
//            }
//        }
//    }
//
//}


//extension PreviewView: AVCaptureFileOutputRecordingDelegate{
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        didFinishRecordingTo?(outputFileURL)
//        print(outputFileURL)
//        resetRecording()
//    }
//}
//
//class PreviewView: UIView {
//    private var captureSession: AVCaptureSession?
//    private var shakeCountDown: Timer?
//    let videoFileOutput = AVCaptureMovieFileOutput()
//    var recordingDelegate: AVCaptureFileOutputRecordingDelegate!
//    var recorded = 0
//    var secondsToReachGoal = 60
//
//    var onRecord: ((Int, Int)->())?
//    var onReset: (() -> ())?
//    var onComplete: (() -> ())?
//    var didFinishRecordingTo: ((URL) -> ())?
//
//    init() {
//        super.init(frame: .zero)
//
//        var allowedAccess = false
//        let blocker = DispatchGroup()
//        blocker.enter()
//        AVCaptureDevice.requestAccess(for: .video) { flag in
//            allowedAccess = flag
//            blocker.leave()
//        }
//        blocker.wait()
//
//        if !allowedAccess {
//            print("!!! NO ACCESS TO CAMERA")
//            return
//        }
//
//        // setup session
//        let session = AVCaptureSession()
//        session.beginConfiguration()
//
//        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                  for: .video, position: .front)
//        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
//            print("!!! NO CAMERA DETECTED")
//            return
//        }
//        session.addInput(videoDeviceInput)
//        session.commitConfiguration()
//        self.captureSession = session
//    }
//
//    override class var layerClass: AnyClass {
//        AVCaptureVideoPreviewLayer.self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
//        let layer = layer as! AVCaptureVideoPreviewLayer
//        layer.videoGravity = .resizeAspectFill
//        return layer
//    }
//
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        recordingDelegate = self
//        startTimers()
//        if nil != self.superview {
//            self.videoPreviewLayer.session = self.captureSession
//            self.videoPreviewLayer.videoGravity = .resizeAspect
//            self.captureSession?.startRunning()
//            self.startRecording()
//        } else {
//            self.captureSession?.stopRunning()
//        }
//    }
//
//    private func onTimerFires(){
//        print("🟢 RECORDING \(videoFileOutput.isRecording)")
//        secondsToReachGoal -= 1
//        recorded += 1
//        onRecord?(secondsToReachGoal, recorded)
//        if(secondsToReachGoal <= 0){
//            stopRecording()
//            shakeCountDown?.invalidate()
//            shakeCountDown = nil
//            onComplete?()
//        }
//    }
//
//    func startTimers(){
//        if shakeCountDown == nil {
//            shakeCountDown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
//                self?.onTimerFires()
//            }
//        }
//    }
//
//    func startRecording(){
//        captureSession?.addOutput(videoFileOutput)
//
//        let filePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(UUID().uuidString).mov")
//
//        videoFileOutput.startRecording(to: filePath, recordingDelegate: recordingDelegate)
//
//    }
//    func resetRecording(){
//        print("resetRecording")
//        stopRecording()
//        shakeCountDown?.invalidate()
//        shakeCountDown = nil
//        //removeFile()
//    }
//
//    func removeFile() {
//        if let url = videoFileOutput.outputFileURL{
//            do {
//                try FileManager.default.removeItem(at: url)
//                print("remove")
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func stopRecording(){
//        videoFileOutput.stopRecording()
//        print("🔴 RECORDING \(videoFileOutput.isRecording)")
//    }
//}
//
//
//extension FileManager {
//    func clearTmpDirectory() {
//        do {
//            let tmpDirURL = FileManager.default.temporaryDirectory
//            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
//            try tmpDirectory.forEach { file in
//                let fileUrl = tmpDirURL.appendingPathComponent(file)
//                try removeItem(atPath: fileUrl.path)
//            }
//        } catch {
//           //catch the error somehow
//        }
//    }
//}
