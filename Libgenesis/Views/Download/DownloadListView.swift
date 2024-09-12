//
//  DownloadListView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI


struct PlainDownloadTaskView: View {
    let dtask: DownloadTask
    var body: some View {
        HStack {
            Text("\(dtask.progressPercent.toPercentageStr()) | \(dtask.book.title)")
        }
    }
}

struct PlainDownloadListView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var recentManager: RecentlyFilesManager
    var body: some View {
        if downloadManager.downloadTasks.count == 0 {
            Button("<No download task>") {
            }
            .disabled(true)
        } else {
            VStack {
                ForEach(downloadManager.downloadTasks, id: \.self) { dtask in
                    Button(dtask.book.title) {
                        if !dtask.loading, dtask.success {
                            recentManager.preview(dtask.localURL)
                        }
                    }
                }
            }
            Divider()
            Button("Clear Menu") {
                fatalError("Implement clear download menu")
            }
        }
    }
}

struct DownloadTaskView: View {
    @ObservedObject var dtask: DownloadTask
    @EnvironmentObject var recentManager: RecentlyFilesManager
    @State var showErr: Bool = false
    var alreadyDownloaded: Double {
        dtask.progressPercent / 100 * Double(dtask.totalSize ?? 0)
    }
    var body: some View {
        HStack {
            ImageView(url: dtask.book.coverURL, width: 50, height: 50, cornerRadius: 5, defaultImg: "tornado", breathing: false)
                .frame(width: 50, height: 50)
            VStack {
                Text(dtask.book.title)
                    .help(dtask.book.title)
                Text("\(alreadyDownloaded.sizeFormatted()) / \(dtask.totalSize?.sizeFormatted() ?? String(Double.nan))")
                    .font(.footnote)
                Text(dtask.targetURL.absoluteString)
                    .font(.footnote)
            }
            VStack {    // status
                if !dtask.loading, !dtask.suspending { // task is ended.
                    if dtask.success {  //  success
                        Image(systemName: "checkmark.circle.fill")
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                            .foregroundColor(.primary)
                    } else {    // error occured
                        Image(systemName: "exclamationmark.triangle")
                            .frame(width: 30, height: 30)
                            .scaledToFit()
                            .onTapGesture {
                                showErr.toggle()
                            }
                            .popover(isPresented: $showErr) {
                                if let err = dtask.errorStr?.urlDecode() {
                                    ScrollView {
                                        Text(err)
                                            .foregroundColor(.primary)
                                            .padding()
                                            .lineLimit(.max)
                                            .frame(alignment: .leading)
                                    }
                                    .frame(width: 400)
                                    .frame(maxHeight: 200)
                                }
                            }
                            .foregroundColor(.yellow)

                    }
                } else if !dtask.loading, dtask.suspending { // suspending
                    Image(systemName: "play.circle.fill")
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                        .foregroundColor(.green)
                        .onTapGesture {
                            dtask.resume()
                        }
                } else {    // downloading
                    Text("\(.percentage(percent: dtask.progressPercent))")
                }
            }
            .frame(width: 60)

        }
        .lineLimit(1)
        .foregroundColor(.primary)
        .contextMenu {
            if dtask.loading, !dtask.suspending {
                Button("Pause") {
                    dtask.pause()
                }
            } else if !dtask.loading, dtask.suspending {
                Button("Resume") {
                    dtask.resume()
                }
            } else if !dtask.loading, !dtask.suspending {
                Button("Re-download") {
                    dtask.resume()
                }
            }
            Divider()

            Button("Reveal in Finder") {
                LibgenesisApp.jumpTo(dtask.localURL)
            }
            Button("Open in Preview") {
                recentManager.preview(dtask.localURL)
            }
            Divider()
            Button("Resume all") {
                DownloadManager.shared.resumeAll()
            }
            Button("Pause all") {
                DownloadManager.shared.pauseAll()
            }
            Divider()
            Button("Remove from list") {
                DownloadManager.shared.removeDownloadTask(dtask)
            }
            Button("Remove all(this will also cancel any tasks in progress!)") {
                DownloadManager.shared.clear()
            }
        }
    }
}

struct DownloadListView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    @State var selectedTask: DownloadTask?
    var body: some View {
        List(downloadManager.downloadTasks, id: \.self, selection: $selectedTask) { dtask in
            DownloadTaskView(dtask: dtask)
            Divider()
        }
        .listStyle(.sidebar)
        .padding(5)
    }
}

struct DownloaderView: View {
    @EnvironmentObject var downloadManager: DownloadManager
    var body: some View {
        DownloadListView()
            .navigationTitle("Downloader")
            .toolbar {
                Button("Clear") {
                    downloadManager.clear()
                }
            }
    }
}

struct DownloadListView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadListView()
    }
}
