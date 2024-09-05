//
//  DownloadListView.swift
//  Libgenesis
//
//  Created by Fish on 5/9/2024.
//

import SwiftUI

struct DownloadTaskView: View {
    @State var dtask: DownloadTask
    var body: some View {
        HStack {
            Image(systemName: "book.closed")
            Text(dtask.book.title)
                .lineLimit(2)
                .help(dtask.book.title)
        }
    }
}

struct DownloadListView: View {
    @ObservedObject var downloadManager = DownloadManager.shared
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                ForEach(downloadManager.downloadTasks) { dtask in
                    DownloadTaskView(dtask: dtask)
                }
            }
        }
        .frame(width: 200, height: 200)
        .padding()
    }
}

struct DownloadListView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadListView()
    }
}
