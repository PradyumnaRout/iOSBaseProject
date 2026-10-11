//
//  VerifyOtpView.swift
//  FreshMorning
//
//  Created by hb on 07/10/26.
//

import SwiftUI
import Combine

struct VerifyOtpView: View {
    @AppStorage("otpTimerEndTime") private var endTime: Double = 0
    @Environment(\.scenePhase) private var scenePhase
    @State private var animate = false
    @State private var secondsRemaining = 0
    @State private var otp: String = ""

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    var body: some View {
        ZStack {
            Color(hex: "#0A122A")
                .ignoresSafeArea()
            
            VStack {
                navHeader
                    .padding(.horizontal)
                ScrollView {
                    content
                        .padding(.vertical)
                }
                .scrollBounceBehavior(.basedOnSize)
                Spacer()
            }
            .onAppear {
                if endTime > Date().timeIntervalSince1970 {
                    updateRemaining(animated: false)
                } else {
                    startTimer()
                }
            }
            .onReceive(timer) { _ in updateRemaining(animated: true) }
            .onChange(of: scenePhase) {_, newPhase in
                if newPhase == .active { updateRemaining(animated: false) }
            }
        }
        //.ignoresSafeArea(.keyboard)
    }
    
    /// Navigation Bar
    @ViewBuilder
    private var navHeader: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.trailing)
                .onTapGesture {
                    // Pop Bakc
                }
            
            Image("protectionRect")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .padding(.trailing, 5)
            
            Text("OTP")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(Color.white)
            
            Spacer()
            
            Image(systemName: "person")
                .padding()
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.black)
                .background(
                    Color(hex: "#C3C0FF")
                )
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .onTapGesture {
                    print("Navigate to profile")
                }
        }
    }
    
    /// Content
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 22) {
            Image(systemName: "checkmark.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(Color(hex: "#C3C0FF"))
                .padding(.all, 25)
                .background(
                    Color(hex: "#3E4660")
                        .opacity(animate ? 1.0 : 0.5)
                        
                )
                .clipShape(Circle())
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                    ) {
                            animate = true
                        }
                }
            
            VStack(spacing: 13) {
                Text("Verification Code")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color(hex: "#E2DFFF"))
                
                HStack {
                    Text("Sent to")
                        .foregroundStyle(Color(hex: "#BEC5E5"))
                    
                    Text("+1 (555) 382-9014")
                        .foregroundStyle(Color(hex: "#E2DFFF"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#282F49"))
                        )
                    
                    Button {
                        // Edit Number
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color(hex: "#C3C0FF"))
                    }
                    .padding(.leading, 6)
                }
            }
            
            VStack(spacing: 22) {
                OTPView(otpCount: 6) { otp in
                    print(otp)
                    self.otp = otp
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(spacing: 12) {
                    if secondsRemaining > 0 {
                        HStack(spacing: 10) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(Color(hex: "#C3C0FF"))
                                .font(.system(size: 18, weight: .medium))
                            Text("Resend OTP in")
                                .foregroundStyle(Color(hex: "#BEC5E5"))
                            
                            RollingTimerText(seconds: secondsRemaining)
                                .foregroundColor(.orange)
                        }
                    } else {
                        Button("Resend OTP") { resendOTP() }
                            .foregroundStyle(Color(hex: "#4CD7F6"))
                    }
                    
                    
                    HStack(alignment: .center, spacing: 20) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("Send via WhatsApp")
                                .offset(y: -2)
                        }
                        .foregroundStyle(Color(hex: "#4CD7F6"))
                        
                        Text("•")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundStyle(Color(hex: "#565D79"))
                        
                        Text("Call me instead")
                            .offset(y: -2)
                            .foregroundStyle(Color(hex: "#BEC5E5"))
                    }
                }
            }
            
            // Verify Button
            VStack(spacing: 18) {
                Button {
                    // Verify Otp
                    print("Verify pressed!")
                } label: {
                    HStack {
                        Text("Verify & Continue")
                        Image(systemName: "arrow.right")
                            .opacity(otp.count == 6 ? 1.0 : 0.6)
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(hex: "#E2DFFF").opacity(otp.count == 6 ? 1.0 : 0.6))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "#4D44E3").opacity(0.8).opacity(otp.count == 6 ? 1.0 : 0.5))
                    )
                    .padding(.horizontal)
                }
                .disabled(otp.count != 6)
                
                Button {
                    
                } label: {
                    Text("Try another verification method")
                        .foregroundStyle(Color(hex: "#BEC5E5"))
                }

            }
        }
    }
    
    private func startTimer() {
        endTime = Date().timeIntervalSince1970 + 60
        updateRemaining(animated: false)
    }
    
    private func updateRemaining(animated: Bool) {
        let remaining = endTime - Date().timeIntervalSince1970
        let newValue = max(0, Int(remaining.rounded(.up)))
        guard newValue != secondsRemaining else { return }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                secondsRemaining = newValue
            }
        } else {
            secondsRemaining = newValue   // no animation when jumping after background
        }
    }
    
    private func resendOTP() {
        // Call your resend API here
        startTimer()
    }
}


// Preview
#Preview {
    VerifyOtpView()
}
