//
//  LoginView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-01.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    
    // user input
    @State private var email = ""
    @State private var password = ""
    
    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    private var isButtonDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
        
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    BackgroundView()
                    
                    VStack(spacing: 15) {
                        Spacer()
                        
                        Text("Event Locator")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.red, .black, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(radius: 5)
                        
                        Image("app-logo")
                            .resizable()
                            .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.3)
                        
                        Group {
                            LabelledTextField(label: "Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                            
                            LabelledTextField(label: "Password", text: $password, type: .Secure)
                            
                        }
                        
                        Button {
                            login()
                        } label: {
                            if authManager.authState == .Unauthenticated {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                            }
                            else if authManager.authState == .Authenticating {
                                ProgressView()
                                    .tint(.white)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .responsiveRoundedStyle(geometry: geo, backgroundColor: isButtonDisabled ? .gray : .primary)
                        .disabled(isButtonDisabled)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text("Not a member? Register here")
                                .bold()
                        }

                        Spacer()
                    }//VStack
                    .padding(.horizontal, 35)
                }//ZStack
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMsg)
            }
        }
    }
    
    private func login() {
        Task {
            if await !authManager.login(email: self.email, password: self.password) {
                alertTitle = "Error"
                alertMsg = authManager.errMsg
                showingAlert.toggle()
                return
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
