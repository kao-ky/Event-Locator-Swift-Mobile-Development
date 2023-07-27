//
//  EventDetailSingleDataRowView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-06.
//

import SwiftUI

struct SingleDataRowView: View {
    let spacing: CGFloat
    let systemName: String      // image str
    let logoWidth: CGFloat
    let logoHeight: CGFloat
    let text: String
    
    init(spacing: CGFloat, systemName: String, logoWidth: CGFloat, logoHeight: CGFloat, text: String) {
        self.spacing = spacing
        self.systemName = systemName
        self.logoWidth = logoWidth
        self.logoHeight = logoHeight
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: logoWidth, height: logoHeight)
            
                Text(text)
        }
    }
}

struct SingleDataRowView_Previews: PreviewProvider {
    static var previews: some View {
        SingleDataRowView(
            spacing: 15,
             systemName: "person",
             logoWidth: 20,
             logoHeight: 20,
             text: "Hello World"
        )
    }
}
