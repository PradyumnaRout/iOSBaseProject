//
//  SignInView.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

enum FocusField: Hashable {
    case username
    case phone
    case password
}

struct SignInView: View {
    
    @Environment(AppEntryModel.self) private var type
    
    // State properties
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = true
    
    @FocusState private var focusField: FocusField?
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(.vertical) {
                VStack {
                    Image("loginImage")
                        .resizable()
                        .scaledToFit()
                    
                    registerHeader
                        .padding(.bottom, 50)
                    requireFields
                    
                    actionButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .contentMargins(.bottom, 30, for: .scrollContent)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(for: String.self) { value in
                switch value {
                case "signUp":
                    SignupView()
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private var actionButton: some View {
        VStack {
            Button {
                print("Login tapped")
                type.entryType = .user(UserRegistery.shared.getCurrentUser(type: "Registered") ?? GuestUser())
            } label: {
                Text("Sing Up")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#1E2D42"))
                    )
            }
            .padding(.horizontal, 35)
            .padding(.vertical)
            
            
            HStack(spacing: 6) {
                Text("Don't have an account?")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: "#64748B"))
                
                Button {
                    path.append("signUp")
                } label: {
                    Text("Sign In")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#1E2D42"))
                }

            }
        }

    }
    
    @ViewBuilder
    private var registerHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Login")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color(hex: "#1E2D42"))
            
            Text("Please sign in to login")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(hex: "#64748B"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 35)
    }
    
    @ViewBuilder
    private var requireFields: some View {
        VStack(spacing: 12) {
            returnField(icon: "person", placeholder: "Username", value: $username, focus: .username)
                .onSubmit {
                    focusField = .password
                }
                .submitLabel(.next)
            returnField(icon: "lock", placeholder: "Supersecret", value: $password, isPasswordVisible: $isPasswordVisible, isSecure: true, focus: .password)
                .submitLabel(.done)
            
            HStack {
                Text("Remember me next time")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: "#334155"))
                
                Spacer()
                
                Toggle("", isOn: $rememberMe)
            }
            .padding(.horizontal, 4)
            .padding(.top, 10)
        }
        .padding(.horizontal, 35)
    }
    
    @ViewBuilder
    private func returnField(
        icon: String,
        placeholder: String,
        value: Binding<String>,
        isPasswordVisible: Binding<Bool> = .constant(false),
        isSecure: Bool = false,
        focus: FocusField
    ) -> some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(hex: "#64748B"))
            
            if isSecure && !isPasswordVisible.wrappedValue {
                SecureField(placeholder, text: value)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: "#94A3B8"))
                    .focused($focusField, equals: focus)
            } else {
                TextField(placeholder, text: value)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(hex: "#94A3B8"))
                    .focused($focusField, equals: focus)
            }
            
            if isSecure {
                Button {
                    isPasswordVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: isPasswordVisible.wrappedValue ? "eye" : "eye.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#64748B"))
                }
            }

        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color(hex: "#F1F4F9"))
        )
    }
}

#Preview {
    SignInView()
}
