//
//  OTPTextViewRepresentable.swift
//  FreshMorning
//
//  Created by hb on 01/10/26.
//

import SwiftUI
import UIKit

final class BackspaceTextField: UITextField {
    var onBackspace: ((Bool) -> Void)?

    override func deleteBackward() {
        let wasEmpty = text?.isEmpty ?? true

        super.deleteBackward()

        onBackspace?(wasEmpty)
    }
}

struct OTPTextField: UIViewRepresentable {
    @Binding var text: String
    var onBackspace: (Bool) -> Void

    func makeUIView(context: Context) -> BackspaceTextField {
        let textField = BackspaceTextField()
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.textAlignment = .center
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textChanged(_:)),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(
        _ uiView: BackspaceTextField,
        context: Context
    ) {
        context.coordinator.parent = self

        if uiView.text != text {
            uiView.text = text
        }

        uiView.onBackspace = onBackspace
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: OTPTextField

        init(parent: OTPTextField) {
            self.parent = parent
        }

        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
