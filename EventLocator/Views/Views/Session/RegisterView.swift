//
//  RegisterView.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import PhotosUI
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    private let eventManager = EventViewModel.getInstance()
    @Environment(\.dismiss) var dismiss
    
    // user input
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // button control
    private var isButtonDisabled: Bool {
        name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    }
    
    // alert
    @State private var isAccountCreated = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundView()
                
                VStack(spacing: 20) {
//                    PhotosPicker(selection: $avatarItem, matching: .images) {
//                        VStack {
//                            (avatarImage ?? Image(systemName: "person.crop.circle"))
//                                .resizable()
//                                .frame(width: 200, height: 200)
//                                .foregroundColor(.white)
//                                .clipShape(Circle())
//
//                            Text("Set Profile Picture")
//                        }
//                    }
//                    .onChange(of: avatarItem) { _ in
//                        Task {
//                            if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
//                                if let uiImage = UIImage(data: data) {
//                                    avatarImage = Image(uiImage: uiImage)
//                                    return
//                                }
//                            }
//                        }
//                    }
                    
                    // not using photos feature in this project so replaced by this
                    Image("app-logo")
                        .resizable()
                        .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.3)
                    
                    VStack(spacing: 15) {
                        LabelledTextField(label: "Name", text: $name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)

                        LabelledTextField(label: "Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                        
                        LabelledTextField(label: "Password", text: $password, type: .Secure)
                        
                        LabelledTextField(label: "Confirm Password", text: $confirmPassword, type: .Secure)
                    }
                    
                    Button {
                        Task {
                            isAccountCreated = await registerUser()
                            showingAlert.toggle()
                        }
                    } label: {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                    }
                    .responsiveRoundedStyle(
                        geometry: geo,
                        backgroundColor: isButtonDisabled ? .gray : .primary
                    )
                    .disabled(isButtonDisabled)

                }
                .padding(.horizontal, 35)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                if isAccountCreated {
                    dismiss()
                }
            }
        } message: {
            Text(alertMsg)
        }
    }
    
    private func registerUser() async -> Bool {
        
        if password != confirmPassword {
            alertTitle = "Error"
            alertMsg = "Mismatching Passwords"
            return false
        }
        
        if await !authManager.register(email: self.email, password: self.password) {
            alertTitle = "Error"
            alertMsg = authManager.errMsg
            return false
        }
        
        if await eventManager.addUserInfo(withEmail: self.email, name: self.name) {
            alertTitle = "Registration Error"
            alertMsg = "Encountered a problem when saving user information to database"
            return false
        }
        
        alertTitle = "Registration Success"
        alertMsg = "Account created"
        return true
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
