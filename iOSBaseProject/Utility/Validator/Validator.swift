//
//  Validator.swift
//  FreshMorning
//
//  Created by hb on 30/10/26.
//

import Foundation

/// Validator Protocol
protocol FieldValidator {
    func validate(_ value: String) -> ValidationResult
}


/// Validation Result
enum ValidationResult {
    case valid
    case invalid(String)
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
    
    var isValid: Bool {
        if case .valid = self {
            return true
        }
        
        return false
    }
}


// MARK: - Individual Validator

/// Required Validator
struct RequiredValidator: FieldValidator {
    let message: String
    
    init(message: String = "This field is required.") {
        self.message = message
    }
    
    func validate(_ value: String) -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? .invalid(message)
        : .valid
    }
}


/// Email Validator
struct EmailValidator: FieldValidator {

    func validate(_ value: String) -> ValidationResult {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        
        let isValid = value.range(
            of: pattern,
            options: .regularExpression
        ) != nil
        
        return isValid
        ? .valid
        : .invalid("Please enter a valid email address.")
    }
}


/// MinLengthValidator
struct MinLengthValidator: FieldValidator {
    
    let minimumLength: Int
    
    func validate(_ value: String) -> ValidationResult {
        value.count >= minimumLength
        ? .valid
        : .invalid("Minimum \(minimumLength) characters required.")
    }
}


/// Phone Number Validator
struct PhoneNumberValidator: FieldValidator {
    
    let minimumLength: Int
    let maximumLength: Int
    
    func validate(_ value: String) -> ValidationResult {
        let digits = value.filter { $0.isNumber }
        
        guard digits.count >= minimumLength,
              digits.count <= maximumLength else {
            return .invalid("Please enter a valid phone number.")
        }
        
        return .valid
    }
}


/// Password Validator
struct PasswordValidator: FieldValidator {
    
    func validate(_ value: String) -> ValidationResult {
        guard value.count >= 8 else {
            return .invalid("Password must contain at least 8 characters.")
        }
        
        guard value.rangeOfCharacter(
            from: .uppercaseLetters
        ) != nil else {
            return .invalid("Password must contain an uppercase letter.")
        }
        
        guard value.rangeOfCharacter(
            from: .decimalDigits
        ) != nil else {
            return .invalid("Password must contain a number.")
        }
        
        return .valid
    }
}

struct URLValidator: FieldValidator {

    func validate(_ value: String) -> ValidationResult {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            return .invalid("URL is required.")
        }

        guard let url = URL(string: trimmedValue),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = url.host,
              host.contains(".")
        else {
            return .invalid("Please enter a valid URL.")
        }

        return .valid
    }
}

/*
 let validator = URLValidator()

 print(validator.validate("https://www.apple.com"))  // valid
 print(validator.validate("http://google.com"))       // valid
 print(validator.validate("www.google.com"))          // invalid
 print(validator.validate("https://"))               // invalid
 print(validator.validate("abc"))                     // invalid
 */



protocol FormLevelValidator {
    func validate(
        _ fields: [String: String]
    ) -> ValidationResult
}

struct ConfirmPasswordValidator: FormLevelValidator {

    func validate(
        _ fields: [String: String]
    ) -> ValidationResult {

        guard fields["password"] == fields["confirmPassword"] else {
            return .invalid("Passwords do not match.")
        }

        return .valid
    }
}

