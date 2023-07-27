//
//  EventDetailDualDataRowView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-06.
//

import SwiftUI

struct DualDataRowView: View {
    let spacing: CGFloat
    let systemName: String      // image str
    let logoWidth: CGFloat
    let logoHeight: CGFloat
    let topText: String
    let bottomText: String
    
    init(spacing: CGFloat, systemName: String, logoWidth: CGFloat, logoHeight: CGFloat, topText: String, bottomText: String) {
        self.spacing = spacing
        self.systemName = systemName
        self.logoWidth = logoWidth
        self.logoHeight = logoHeight
        self.topText = topText
        self.bottomText = bottomText
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: logoWidth, height: logoHeight)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(topText)
                
                Text(bottomText)
                    .font(.footnote)
            }
        }
    }
}

struct DualDataRowView_Previews: PreviewProvider {
    static var previews: some View {
        DualDataRowView(
            spacing: 15,
             systemName: "person",
             logoWidth: 20,
             logoHeight: 20,
             topText: "Hello",
             bottomText: "World"
        )
    }
}
