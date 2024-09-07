//
//  Animations.swift
//  Libgenesis
//
//  Created by Fish on 7/9/2024.
//

import SwiftUI

extension View {
    func breathingEffect() -> some View {
        self.modifier(BreathingEffect())
    }
    func hoveringEffect(_ factor: Double = 0.1, duration: Double = 1) -> some View {
        self.modifier(HoveringEffect(factor, duration: duration))
    }
}

struct BreathingEffect: ViewModifier {
    @State private var isOpaque = false

    func body(content: Content) -> some View {
        ZStack {
            Color.black
                .opacity(isOpaque ? 0.1 : 0.0)  // 控制透明度
                .edgesIgnoringSafeArea(.all)
                .animation(
                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: isOpaque
                )
            
            content
                .onAppear {
                    self.isOpaque.toggle()
                }
        }
    }
}

struct HoveringEffect: ViewModifier {
    @State private var isOpaque = false
    private var opac: Double
    private var dura: Double
    
    init(_ factor: Double, duration: Double) {
        opac = factor
        dura = duration
    }

    func body(content: Content) -> some View {
        ZStack {
            Color.gray
                .opacity(isOpaque ? opac : 0.0)
                .edgesIgnoringSafeArea(.all)
                .animation(
                    Animation.easeInOut(duration: dura),
                    value: isOpaque
                )
            
            content
                .onHover { h in
                    isOpaque = h
//                    print("Hovering: \(h)")
                }
        }
    }
}

struct Animations_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
