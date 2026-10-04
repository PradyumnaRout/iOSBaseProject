//
//  OTPView.swift
//  FreshMorning
//
//  Created by hb on 01/10/26.
//

import Foundation
import SwiftUI

struct OTPView: View {
    let otpCount: Int
    let supportEmptyBackspace: Bool
    @Binding var otp: String
    var onComplete: ((String) -> Void)?
    
    @State private var digits: [String]
    @State private var isPasting = false
    @FocusState private var focusedIndex: Int?
    
    init(
        otp: Binding<String>,
        otpCount: Int = 4,
        supportEmptyBackspace: Bool = true,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._otp = otp
        self.otpCount = otpCount
        self.supportEmptyBackspace = supportEmptyBackspace
        self.onComplete = onComplete
        
        let initialText = otp.wrappedValue
        let initialDigits = (0..<otpCount).map { i -> String in
            if i < initialText.count {
                let charIndex = initialText.index(initialText.startIndex, offsetBy: i)
                return String(initialText[charIndex])
            }
            return ""
        }
        _digits = State(initialValue: initialDigits)
    }
    
    init(
        otpCount: Int = 4,
        supportEmptyBackspace: Bool = true,
        onComplete: ((String) -> Void)? = nil
    ) {
        self.init(
            otp: .constant(""),
            otpCount: otpCount,
            supportEmptyBackspace: supportEmptyBackspace,
            onComplete: onComplete
        )
    }
    
    var body: some View {
        VStack {
            otpContent
        }
        .padding(20)
        .onChange(of: otp) { _, newOTP in
            syncDigitsFromOTP(newOTP)
        }
    }
    
    private var otpContent: some View {
        HStack {
            ForEach(0..<otpCount, id: \.self) { index in
                inputField(for: index)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.clear)
                    .focused($focusedIndex, equals: index)
                    .modifier(OTPModifier(isFocused: focusedIndex == index, isFilled: !digits[index].isEmpty))
                    .disabled(!canEdit(at: index))
                    .onChange(of: digits[index]) { oldValue, newValue in
                        handleTextChange(at: index, oldValue: oldValue, newValue: newValue)
                    }
            }
        }
        .onAppear {
            if focusedIndex == nil, digits.first?.isEmpty == true {
                focusedIndex = 0
            }
        }
    }
    
    @ViewBuilder
    private func inputField(for index: Int) -> some View {
        if supportEmptyBackspace {
            OTPTextField(text: $digits[index]) { _ in
                focusPrev(from: index)
            }
        } else {
            TextField("", text: $digits[index])
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
        }
    }
    
    private func handleTextChange(at index: Int, oldValue: String, newValue: String) {
        guard !isPasting else { return }
        
        let numericOnly = newValue.filter { "0123456789".contains($0) }
        
        // Handle pasted text or SMS auto-fill containing multiple digits
        if numericOnly.count > 1 {
            isPasting = true
            
            let chars = Array(numericOnly)
            for (offset, char) in chars.enumerated() {
                let targetIndex = index + offset
                guard targetIndex < otpCount else { break }
                digits[targetIndex] = String(char)
            }
            syncOTP()
            
            let lastFilledIndex = min(index + chars.count, otpCount - 1)
            focusedIndex = (digits.allSatisfy { !$0.isEmpty }) ? nil : lastFilledIndex
            
            DispatchQueue.main.async {
                isPasting = false
            }
            return
        }
        
        // Single digit or empty
        let singleDigit = String(numericOnly.prefix(1))
        if digits[index] != singleDigit {
            digits[index] = singleDigit
        }
        syncOTP()
        
        if !singleDigit.isEmpty {
            focusNext(from: index)
        } else {
            focusPrev(from: index)
        }
    }
    
    private func syncOTP() {
        let combined = digits.joined()
        if otp != combined {
            otp = combined
        }
        if combined.count == otpCount {
            onComplete?(combined)
        }
    }
    
    private func syncDigitsFromOTP(_ newOTP: String) {
        let newDigits = (0..<otpCount).map { i -> String in
            if i < newOTP.count {
                let charIndex = newOTP.index(newOTP.startIndex, offsetBy: i)
                return String(newOTP[charIndex])
            }
            return ""
        }
        if digits != newDigits {
            digits = newDigits
        }
    }
    
    private func focusNext(from index: Int) {
        if index + 1 < otpCount {
            focusedIndex = index + 1
        } else {
            focusedIndex = nil
        }
    }
    
    private func focusPrev(from index: Int) {
        if index - 1 >= 0 {
            focusedIndex = index - 1
        }
    }
    
    private func canEdit(at index: Int) -> Bool {
        index == 0 || !digits[index - 1].isEmpty
    }
}


#Preview {
    OTPView(otpCount: 6)
}
