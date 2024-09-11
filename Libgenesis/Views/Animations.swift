//
//  Animations.swift
//  Libgenesis
//
//  Created by Fish on 7/9/2024.
//

import SwiftUI

extension View {
    func breathingEffect(_ factor: Double = 0.1) -> some View {
        self.modifier(BreathingEffect(factor: factor))
    }
    func hoveringEffect(_ factor: Double = 0.1, duration: Double = 1, radius: Double = 0) -> some View {
        self.modifier(HoveringEffect(factor, duration: duration, radius: radius))
    }
    func textSelectable(_ scheme: ColorScheme) -> some View {
        self.modifier(SelectableViewModifier(scheme: scheme))
    }
}

extension Text {
    func leftAlign(width: Double) -> some View {
        self.frame(width: width, alignment: .leading)
    }
}

struct BreathingEffect: ViewModifier {
    @State private var isOpaque = false
    let factor: Double

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
    private var radius: Double
    
    init(_ factor: Double, duration: Double, radius: Double) {
        opac = factor
        dura = duration
        self.radius = radius
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
                .cornerRadius(radius)
            
            content
                .onHover { h in
                    isOpaque = h
//                    print("Hovering: \(h)")
                }
        }
    }
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .opacity(configuration.isOn ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .hoveringEffect(0.5, duration: 0.5, radius: 5)
    }
}

struct PlainCheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: "checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .opacity(configuration.isOn ? 1 : 0)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

extension ToggleStyle where Self == CheckmarkToggleStyle {
    static var checkmark: CheckmarkToggleStyle {
        CheckmarkToggleStyle()
    }
    static var plainCheckmark: PlainCheckmarkToggleStyle {
        PlainCheckmarkToggleStyle()
    }
}

struct SearchBar: View {
    @Binding var search: String
    let prompt: String
    let perform: () -> Void
    
    init(_ search: Binding<String>, prompt: String = "search...", perform: @escaping () -> Void) {
        self._search = search
        self.prompt = prompt
        self.perform = perform
    }
    
    var body: some View {
        HStack(spacing: 5) {
            TextField(prompt, text: $search)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    perform()
                }
            Button(action: {
                perform()
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
        .frame(minWidth: 150)
    }
}

struct SelectableViewModifier: ViewModifier {
    var scheme: ColorScheme

    func body(content: Content) -> some View {
        content
            .textSelection(.enabled)
            .foregroundColor(scheme == .light ? .black : .white)
    }
}


struct Animations_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
