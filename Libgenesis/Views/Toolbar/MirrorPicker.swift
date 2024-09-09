//
//  MirrorConfigureView.swift
//  Libgenesis
//
//  Created by Fish on 9/9/2024.
//

import SwiftUI

struct MirrorPicker: View {
    @AppStorage("libgenMirrors") var libgenMirrors: [ServerMirror] = ServerMirror.defaults
    @AppStorage("baseURL") var selection: String = ServerMirror.defaultMirror.description

    var body: some View {
        Picker("Server:", selection: $selection) {
            ForEach(libgenMirrors, id: \.self) { m in
                Text(m.domain).tag(m.url.absoluteString)
            }
        }
        .help("Choose mirrors.")
    }
}

struct MirrorAdder: View {
    @Binding var showSheet: Bool
    var body: some View {
        Button(action: {
            showSheet.toggle()
        }) {
            Label("New mirror", systemImage: "plus")
                .imageScale(.medium)
        }
        .help("Add new mirror")
    }

}

struct MirrorSubmitSheet: View {
    @Binding var showSheet: Bool
    @AppStorage("libgenMirrors") var libgenMirrors: [ServerMirror] = ServerMirror.defaults
    @State var err: Bool = false
    @State var url: String = ""
    var body: some View {
        Form {
            TextField("Mirror url:", text: $url)
            VStack(alignment: .leading) {
                Text("Tips: just domain name, no path, no query, example: https://libgen.is")
                Text("Ensure that mirror has the same API of original libgen.is")
                Text(".i.e - search api is example.com/search.php?req=xxx&column=xxx")
                Text("And, book api is: example.com/index.php?md5=...")
                if err {
                    Divider()
                    Text("Add new mirror failed: invalid url or repeated.")
                        .foregroundColor(.red)
                    Divider()
                }
            }
            .bold()
            .lineLimit(15)

            HStack {
                Button("Add") {
                    onsubmit()
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    showSheet.toggle()
                }
            }
        }
        .frame(width: 500)
        .padding()

    }
    
    private func onsubmit() {
        // check format, and not contains in existing mirrors.
        if let mirror = ServerMirror(url), !libgenMirrors.contains(where: { $0.url == mirror.url }) {
            libgenMirrors.append(mirror)
            showSheet.toggle()
            err = false
        } else {
            err = true
        }
    }
}

struct MirrorDeleter: View {
    @AppStorage("baseURL") var selection: String = ServerMirror.defaultMirror.description
    @Binding var showAlert: Bool

    var body: some View {
        Button(action: {
            showAlert.toggle()
            print("Attempt to delete mirror.")
        }) {
            Label("Delete mirror - \(selection)", systemImage: "delete.backward")
                .imageScale(.medium)
        }
    }
}


func MirrorDelAlert() -> Alert {
    @State var isLast: Bool = false
    @AppStorage("libgenMirrors") var libgenMirrors: [ServerMirror] = ServerMirror.defaults
    @AppStorage("baseURL") var selection: String = ServerMirror.defaultMirror.description
    return (
        Alert(title: Text("Are you sure?"),
          message: Text(isLast ? "Failed, need at least one server mirror." : "To delete mirror: \(selection)"),
          primaryButton: .cancel(Text("Cancel")),
          secondaryButton: .destructive(
              Text("Delete"),
              action: {
                  if libgenMirrors.count == 1 {
                      isLast = true
                      return
                  } else {
                      isLast = false
                  }
                  delMirror()
              }
          ))
    )
        

}

private func delMirror() {
    @AppStorage("libgenMirrors") var libgenMirrors: [ServerMirror] = ServerMirror.defaults
    @AppStorage("baseURL") var selection: String = ServerMirror.defaultMirror.description
    if let target = libgenMirrors.first(where: { $0.url.absoluteString == selection }) {
        print("Really to delete \(target)")
        //delete mirror
        libgenMirrors.removeAll(where: {target == $0})
        selection = libgenMirrors.first!.url.absoluteString
    } else {
        print("Mirror \(selection) doesn't exist.")
    }
}

struct MirrorConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
