//
//  ReversedScrollView.swift
//  SimpleChat
//
//  Created by Богдан Зыков on 16.12.2022.
//

import SwiftUI

struct ReversedScrollView<Content: View>: View {
    var axis: Axis.Set
    var content: Content
    var showsIndicators: Bool
    var contentSpacing: CGFloat
    
    init(_ axis: Axis.Set = .horizontal,
         showsIndicators: Bool = true,
         contentSpacing: CGFloat = 0,
         @ViewBuilder builder: () -> Content) {
        self.axis = axis
        self.contentSpacing = contentSpacing
        self.showsIndicators = showsIndicators
        self.content = builder()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(axis, showsIndicators: showsIndicators) {
                LazyStack(axis, spacing: contentSpacing) {
                    content
                }
                .vBottom()
                .frame(
                   minWidth: minWidth(in: proxy, for: axis),
                   minHeight: minHeight(in: proxy, for: axis)
                )
            }
        }
    }
}

struct ReversedScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ReversedScrollView(.vertical, contentSpacing: 10) {
            ForEach(0..<15) { item in
                Text("\(item)")
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(6)
            }
            .hLeading()
            .padding(.horizontal)
        }
        
        .background(Color.black.opacity(0.1))
    }
}

extension ReversedScrollView{
    
    private func minWidth(in proxy: GeometryProxy, for axis: Axis.Set) -> CGFloat? {
        axis.contains(.horizontal) ? proxy.size.width : nil
    }
    
    private func minHeight(in proxy: GeometryProxy, for axis: Axis.Set) -> CGFloat? {
        axis.contains(.vertical) ? proxy.size.height : nil
    }
    
}



struct LazyStack<Content: View>: View {
    var axis: Axis.Set
    var content: Content
    var spacing: CGFloat
    
    init(_ axis: Axis.Set = .vertical,
         spacing: CGFloat = 0,
         @ViewBuilder builder: ()->Content) {
        self.axis = axis
        self.spacing = spacing
        self.content = builder()
    }
    
    var body: some View {
        switch axis {
        case .horizontal:
            LazyHStack(spacing: spacing) {
                content
            }
        case .vertical:
            LazyVStack(spacing: spacing) {
                content
            }
        default:
            LazyVStack(spacing: spacing) {
                content
            }
        }
    }
}
