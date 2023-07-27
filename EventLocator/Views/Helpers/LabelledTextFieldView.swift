//
//  LabelledTextFieldView.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import SwiftUI

struct LabelledTextField: View {
    let label: String
    @Binding var text: String
    var type: InputFieldType = .Text
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(label)
                .foregroundColor(Color(.placeholderText))
                .offset(y: text.isEmpty ? 0 : -25)
                .scaleEffect(
                    text.isEmpty ? 1: 0.8,
                    anchor: .leading
                )
            
            if type == .Text {
                TextField(label, text: $text)
            }
            else if type == .Secure {
                SecureField(label, text: $text)
            }
        }
        .frame(height: 50)
        .padding(.top, text.isEmpty ? 0 : 15)
        .padding(.horizontal, 15)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke()
            .foregroundColor(.gray)
        )
        .animation(.default, value: text)
    }
}

struct LabelledTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        @State var text = "123"
        LabelledTextField(label: "Hi", text: $text)
    }
}
