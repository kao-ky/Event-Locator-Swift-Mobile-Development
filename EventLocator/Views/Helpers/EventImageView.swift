//
//  EventImageView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-05.
//

import SwiftUI

struct EventImageView: View {
    let images: [String]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { imageUrl in
                if let url = URL(string: imageUrl) {
                    AsyncImage(url: url,
                               content: {image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                    },
                    placeholder: {
                        ProgressView()
                    })
                } else {
                    Image(systemName: "photo")
                }
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

//struct EventImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventImageView(event: )
//    }
//}
