//
//  RecordManager.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 17.12.2022.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI


class RecordManager : NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var audioRecorder : AVAudioRecorder!
    
    let bufferService: AudioBufferService = AudioBufferService.shared
    
    @Published var recordState: AudioRecordEnum = .empty
    @Published var isLoading: Bool = false
    @Published var uploadURL: URL?
    @Published var toggleColor : Bool = false
    @Published var timerCount : Timer?
    @Published var blinkingCount : Timer?
    @Published var remainingDuration: Double = 0
    @Published var returnedAudio: VoiceAudioModel?
    var lastRecordTime: TimeInterval = .zero
   
    
    override init(){
        super.init()
    }
   
 
    func startRecording(){
        print("DEBUG:", "startRecording")
        AVAudioSessionManager.share.configureRecordAudioSessionCategory()
        
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let audioCachURL = path.appendingPathComponent("CO-Voice : \(UUID().uuidString).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioCachURL, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            recordState = .recording
            timerCount = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (value) in
                self.remainingDuration += 0.1
            })
            blinkColor()
            
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    
    func stopRecording(){
        print("DEBUG:", "stopRecording")
        lastRecordTime = audioRecorder.currentTime
        audioRecorder.stop()
        timerCount!.invalidate()
        blinkingCount!.invalidate()
        prepairAudio()
    }
    
    func cancel(){
        print("DEBUG:", "cancel")
        audioRecorder.stop()
        timerCount!.invalidate()
        blinkingCount!.invalidate()
        returnedAudio = nil
        recordState = .empty
        remainingDuration = 0
    }
    
    func prepairAudio(){
        print("DEBUG:", "prepairAudio")
        let url = audioRecorder.url
        print(remainingDuration)
        bufferService.buffer(url: url, samplesCount: Int(UIScreen.main.bounds.width * 0.5) / 4) {[weak self] decibles in
            guard let self = self else {return}
            self.returnedAudio  = .init(id: UUID().uuidString, url: url, duration: self.lastRecordTime, decibles: decibles)
                self.recordState = .recordered
                self.remainingDuration = 0
               
        }
    }

    func uploadAudio(completion: @escaping (MessageAudio) -> Void){
        print("DEBUG:", "uploadAudio", returnedAudio?.duration)
         guard let returnedAudio = returnedAudio else {return}
         let url = returnedAudio.url
         bufferService.buffer(url: url, samplesCount: 30) {[weak self] decibles in
             guard let self = self else {return}
             let updloadedAudio: MessageAudio = .init(id: returnedAudio.id, url: url, duration: returnedAudio.duration, decibles: decibles)
             completion(updloadedAudio)
             self.recordState = .empty
         }
         
//         isLoading = true
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid, let url = audioCachURL else {return}
//        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
//        ref.putFile(from: url) {(metadate, error) in
//            if let error = error{
//                print(error.localizedDescription)
//            }
//            ref.downloadURL { url, error in
//                if let error = error{
//                    print(error.localizedDescription)
//                }
//                print(url?.absoluteString ?? "nil url")
//                self.isLoading = false
//                self.uploadURL = url
//            }
//        }
    }
    
    
    private func blinkColor() {
        
        blinkingCount = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (value) in
            self.toggleColor.toggle()
        })
        
    }
}



enum AudioRecordEnum: Int{
    case recording, recordered, empty
}


extension TimeInterval {
    var minutesSecondsMilliseconds: String {
        String(format: "%02.0f:%02.0f:%02.0f",
               (self / 60).truncatingRemainder(dividingBy: 60),
               truncatingRemainder(dividingBy: 60),
               (self * 100).truncatingRemainder(dividingBy: 100).rounded(.down))
    }
    var minuteSeconds: String{
        String(format: "%02.0f:%02.0f",
               (self / 60).truncatingRemainder(dividingBy: 60),
               truncatingRemainder(dividingBy: 60))
    }
}
