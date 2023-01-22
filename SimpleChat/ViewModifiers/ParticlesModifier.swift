//
//  ParticlesModifier.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 22.01.2023.
//

import SwiftUI

struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 30 ... 40)
    var direction = Double.random(in: -Double.pi ...  Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}


struct ParticlesModifier: ViewModifier {
    @Binding var show: Bool
    @State var time = 0.0
    @State var scale = 0.5
    var speed: Double = Double.random(in: 10 ... 40)
    var duration = 1.5
    var particlesMaxCount: Int = 20
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<particlesMaxCount, id: \.self) { index in
                content
                    //.hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time, speed: speed))
                    .opacity(((duration-time) / duration))
                    //.rotationEffect(Angle(degrees: time * 10))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 1.0
                show = false
            }
        }
    }
}
