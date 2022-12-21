//
//  CircleProgressBar.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 21.12.2022.
//

import SwiftUI

struct CircleProgressBar: View {
    let total: Float = 60
    @Binding var progress: Float
    var lineWidth: CGFloat = 10
    var bgCircleColor: Color = .clear
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(bgCircleColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / total, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .fill(Material.ultraThinMaterial)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct CircleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.blue
            CircleProgressBar(progress: .constant(60))
                .frame(width: 100)
        }
    }
}

