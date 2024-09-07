//
//  SettingsView.swift
//  Libgenesis
//
//  Created by Fish on 6/9/2024.
//

import SwiftUI
import Combine
import Cocoa

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            NetworkSettigsView()
                .tabItem {
                    Label("Network", systemImage: "network")
                }
            AdvanceSettingsView()
                .tabItem {
                    Label("Advance", systemImage: "hammer")
                }
        }
        .padding()
        .frame(width: 400)
        .frame(maxWidth: .infinity)

    }
}

enum Theme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }
}


struct GeneralView: View {
    @AppStorage("saveDir") var saveDir: String = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path(percentEncoded: true) ?? "/tmp"
    @AppStorage("defaultSaveDir") var defaultSaveDir: String = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path(percentEncoded: true) ?? "/tmp"
    @AppStorage("theme") var theme: Theme = .system
    @AppStorage("autoStart") var autoStart: Bool = false
    var body: some View {
        Form {
            Toggle("Start with system: ", isOn: $autoStart)
                .toggleStyle(.switch)
            TextField("Save location: ", text: $saveDir)
            Picker("Appearance: ", selection: $theme) {
                ForEach(Theme.allCases, id: \.self) { th in
                    Text(th.rawValue.lowercased()).tag(th.id)
                }
            }
        }
        
    }
}

struct AdvanceSettingsView: View {
    @AppStorage("cacheEnabled") var enableCache: Bool = true
    @AppStorage("cacheDir") var cacheDir: String = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path ?? "/tmp"
    
    var body: some View {
        Form {
            Toggle("Enable cache: ", isOn: $enableCache)
                .toggleStyle(.switch)
            TextField("Cache location: ", text: $cacheDir)
            Button("Clear image cache") {
                LibgenesisApp.clearImageCache()
            }
            Button("Clear documents cache") {
                fatalError("Clear documents cache to be implemented.")
            }
        }
    }
}

struct NetworkSettigsView: View {
    @AppStorage("maxDownloadConnNum") var maxDownloadConnNum: Int = 5
    
    var body: some View {
        Form {
            VStack {
                Stepper(value: $maxDownloadConnNum,
                        in: 1...33,
                        step: 1) {
                    Text("Maximum download connections: \(maxDownloadConnNum)")
                }
                Text("Inform: acess will be forbidden if there's too much connection. ")
                    .font(.footnote)
            }

        }

    }
    
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSettigsView()
    }
}
