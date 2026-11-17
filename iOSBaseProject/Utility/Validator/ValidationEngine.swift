//
//  ValidationEngine.swift
//  FreshMorning
//
//  Created by hb on 02/11/26.
//

import Foundation


/// Validation Result
///
struct FormValidationResult {
    
    let error: [String: [String]]
    
    var isValid: Bool {
        error.isEmpty
    }
    
    func error(for field: String) -> String? {
        error[field]?.first
    }
}


/// Validation Engine
///
struct ValidationEngine {
    
    private let rules: [String: [any FieldValidator]]
    
    init(rules: [String : [any FieldValidator]]) {
        self.rules = rules
    }
    
    func validate(
        _ fields: [String: String]
    ) -> FormValidationResult {
        var errors: [String: [String]] = [:]
        
        for (field, validators) in rules {
            
            let value = fields[field] ?? ""
            
            for validator in validators {
                let result = validator.validate(value)
                
                if let message = result.errorMessage {
                    errors[field, default: []].append(message)
                }
            }
        }
        return FormValidationResult(error: errors)
    }
}



// MARK: - Usages
/*
 let registrationValidator = FormValidationEngine(
     rules: [

         "name": [
             RequiredValidator()
         ],

         "email": [
             RequiredValidator(),
             EmailValidator()
         ],

         "password": [
             RequiredValidator(),
             PasswordValidator()
         ],

         "phone": [
             RequiredValidator(),
             PhoneNumberValidator(
                 minimumLength: 10,
                 maximumLength: 10
             )
         ]
     ]
 )
 */


import Observation

@Observable
@MainActor
final class RegistrationViewModel {
    
    var name = ""
    var email = ""
    var password = ""
    var phone = ""
    
    // Validation Errors:
    var validationErrors: [String: [String]] = [:]
    
    // Validator:
    private let validator = ValidationEngine(
            rules: [
                "name": [RequiredValidator()],
                "email": [
                    RequiredValidator(),
                    EmailValidator()
                ],
                "password": [
                    RequiredValidator(),
                    PasswordValidator()
                ],
                "phone": [
                    RequiredValidator(),
                    PhoneNumberValidator(
                        minimumLength: 10,
                        maximumLength: 10
                    )
                ]
            ]
        )
    
    
    func validateForm() -> Bool {
        let result = validator.validate([
            "name": name,
            "email": email,
            "password": password,
            "phone": phone
        ])
        
        validationErrors = result.error
        return result.isValid
    }
    
    func submit() {
        guard validateForm() else {
            return
        }
        print("Form is valid. Submit API request.")
    }
}


import SwiftUI


struct RegistrationView: View {

    @State private var viewModel = RegistrationViewModel()

    var body: some View {
        VStack(spacing: 16) {

            TextField("Name", text: $viewModel.name)

            if let error = viewModel.validationErrors["name"]?.first {
                Text(error)
                    .foregroundStyle(.red)
            }

            TextField("Email", text: $viewModel.email)

            if let error = viewModel.validationErrors["email"]?.first {
                Text(error)
                    .foregroundStyle(.red)
            }

            SecureField("Password", text: $viewModel.password)

            if let error = viewModel.validationErrors["password"]?.first {
                Text(error)
                    .foregroundStyle(.red)
            }

            Button("Register") {
                viewModel.submit()
            }
        }
        .padding()
    }
}


#Preview {
    RegistrationView()
}
