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
    @AppStorage("preferredFormats") var preferredFormats: Set<FormatFilter> = [.def]

    var body: some View {
        VStack {
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
            HStack(alignment: .top) {
                Label("Preferred formats:", systemImage: "line.3.horizontal.decrease.circle")
                VStack {
                    ForEach(FormatFilter.allCases, id: \.self) { format in
                        Toggle(format.desc, isOn: Binding(
                            get: { preferredFormats.contains(format) },
                            set: {
                                if $0 {
                                    preferredFormats.insert(format)
                                } else {
                                    preferredFormats.remove(format)
                                }
                            }
                        ))
                        .frame(height: 20)
                        .toggleStyle(.checkmark)
                    }
                }
            }
        }
        
    }
}

struct AdvanceSettingsView: View {
    @AppStorage("cacheEnabled") var enableCache: Bool = true
    @AppStorage("cacheDir") var cacheDir: String = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path ?? "/tmp"
    @AppStorage("perPageN") var perPageN: Int = 25
    
    var body: some View {
        VStack {
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
                Picker("Results per page", selection: $perPageN) {
                    Text("25").tag(25)
                    Text("50").tag(50)
                    Text("100").tag(100)
                }
            }
        }
    }
}

struct NetworkSettigsView: View {
    @AppStorage("maxDownloadConnNum") var maxDownloadConnNum: Int = 5
    @State var showAddSheet: Bool = false
    @State var showDelAlert: Bool = false
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    MirrorPicker()
                        .pickerStyle(.segmented)
                    MirrorAdder(showSheet: $showAddSheet)
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                    MirrorDeleter(showAlert: $showDelAlert)
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                }
            }
            VStack {
                Stepper(value: $maxDownloadConnNum,
                        in: 1...33,
                        step: 1) {
                    HStack {
                        Text("Maximum download connections: ")
                        Text("\(maxDownloadConnNum)")
                    }
                }
                Text("Inform: acess will be forbidden if there's too much connection. ")
                    .bold()
                    .font(.footnote)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            MirrorSubmitSheet(showSheet: $showAddSheet)
        }
        .alert(isPresented: $showDelAlert) {
            MirrorDelAlert()
        }
    }
    
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSettigsView()
    }
}
