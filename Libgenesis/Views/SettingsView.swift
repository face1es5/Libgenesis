//
//  SettingsView.swift
//  Libgenesis
//
//  Created by Fish on 6/9/2024.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }
}

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
            IntegrationSettingsView()
                .tabItem {
                    Label("Plugin", systemImage: "puzzlepiece.extension")
                }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct GeneralView: View {
    @AppStorage("saveDir") var saveDir: String = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path(percentEncoded: true) ?? "/tmp"
    @AppStorage("theme") var theme: Theme = .system
    @AppStorage("preferredFormats") var preferredFormats: Set<FormatFilter> = [.def]
    @State var showFileSelector: Bool = false

    var body: some View {
        VStack {
            Form {
                HStack {
                    TextField("Save location: ", text: $saveDir)
                    Button(action: {
                        showFileSelector.toggle()
                    }) {
                        Image(systemName: "folder")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 20, height: 20)
                    }
                    .fileImporter(isPresented: $showFileSelector, allowedContentTypes: [.directory]) { res in
                        switch res {
                        case .success(let url):
                            if url.startAccessingSecurityScopedResource() {
                                saveDir = url.path(percentEncoded: false)
                                print("Access save location success: \(url.path(percentEncoded: true))")
                            } else {
                                print("Try to access save location failed: \(url.path(percentEncoded: false))")
                            }
                            break
                        case .failure(let err):
                            print("Select directory failed: \(err)")
                            break
                        }
                    }
                    .buttonStyle(.plain)
                }
                Picker("Appearance: ", selection: $theme) {
                    ForEach(Theme.allCases, id: \.self) { th in
                        Text(th.rawValue.lowercased()).tag(th.id)
                    }
                }
            }
            HStack(alignment: .top) {
                Text("Preferred formats:")
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
                        in: 1...32,
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

struct IntegrationSettingsView: View {
    @AppStorage("useKepubify") var useKepubify: Bool = false
    @State var kepubPopover: Bool = false
    @Environment(\.colorScheme) var scheme: ColorScheme
    var body: some View {
        Form {
            Toggle(isOn: $useKepubify) {
                HStack {
                    Text("Enable kepubify(only supported on macOS)")
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            kepubPopover.toggle()
                        }
                        .popover(isPresented: $kepubPopover, arrowEdge: .trailing) {
                            VStack(alignment: .leading) {
                                Text("Kepubify is the fastest tool for converting EPUBs to Kobo's enhanced KEPUB format for use on Kobo eReaders.")
                                    .textSelectable(scheme)
                                Text("It works with malformed e-books, doesn't modify the book's layout more than absolutely necessary, doesn't depend on any external software, and works from the command-line.")
                                    .textSelectable(scheme)
                                Link("homepage", destination: URL(string: "https://pgaskin.net/kepubify/")!)
                            }
                            .frame(width: 200)
                            .padding()
                        }
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSettigsView()
    }
}
