//
//  ImageView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI
import Kingfisher

struct ImageView: View {
    let url: URL?
    var preferredWidth: CGFloat = 150
    var preferredHeight: CGFloat = 150
    var cornerRadius: CGFloat = 20
    var defaultImg: String
    var breathing: Bool = false
    
    init(url: URL?, defaultImg: String = "eye", breathing: Bool = false) {
        self.url = url
        self.defaultImg = defaultImg
        self.breathing = false
    }
    
    init(url: URL?, width: CGFloat = 150, height: CGFloat = 150, cornerRadius: CGFloat = 20, defaultImg: String = "eye", breathing: Bool = false) {
        self.url = url
        self.preferredWidth = width
        self.preferredHeight = height
        self.cornerRadius = cornerRadius
        self.defaultImg = defaultImg
        self.breathing = breathing
    }
    
    var body: some View {
        if let url = self.url {
            KFImage(url)
                .placeholder {
                    ProgressView()
                        .scaledToFit()
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: preferredWidth, height: preferredHeight))
                              |> RoundCornerImageProcessor(cornerRadius: cornerRadius))
                .cacheMemoryOnly()
                .retry(maxCount: 3, interval: .seconds(5))
                .fade(duration: 1)
                .onSuccess { result in
//                    print("Load image succeed: \(result.source.url?.absoluteString ?? "")")
                }
                .onFailure { error in
                    print("Load image failed: \(error.localizedDescription)")
                }
                .resizable()
                .scaledToFit()
//                .background(Color.clear)
//                .overlay(
//                    RoundedRectangle(cornerRadius: cornerRadius)
//                        .stroke(.clear, lineWidth: 1)
//                )
        } else {
            if breathing {
                Image(systemName: defaultImg)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: preferredWidth, maxHeight: preferredHeight)
                    .breathingEffect()
                    .cornerRadius(cornerRadius)
            } else {
                Image(systemName: defaultImg)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: preferredWidth, maxHeight: preferredHeight)
                    .cornerRadius(cornerRadius)
            }
        }

    }
    
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
