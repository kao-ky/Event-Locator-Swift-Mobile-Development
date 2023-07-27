//
//  CustomNavBackButtonView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-05.
//

import SwiftUI

struct CustomNavBackButtonView: View {
    var label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .bold()
                .offset(x: -8)
            Text("Explore").offset(x: -12)
        }
    }
}

struct CustomNavBackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBackButtonView("Back")
    }
}
