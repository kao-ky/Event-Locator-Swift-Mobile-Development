//
//  ButtonExtension.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import SwiftUI

extension Button {
    func responsiveRoundedStyle(geometry: GeometryProxy, backgroundColor: Color = .primary) -> some View {
        modifier(roundedButtonStyle(geo: geometry, bgColor: backgroundColor))
    }
}
