//
//  RoundedButtonModifier.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import SwiftUI

struct roundedButtonStyle: ViewModifier {
    let geo: GeometryProxy
    let bgColor: Color
    let cornerRadius: CGFloat = 30
    
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .frame(height: geo.size.height * 0.05)
            .foregroundColor(.white)
            .background(bgColor)
            .cornerRadius(cornerRadius)
    }
}
