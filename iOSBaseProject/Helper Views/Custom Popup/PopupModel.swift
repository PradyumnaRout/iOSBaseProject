//
//  PopupModel.swift
//  FreshMorning
//
//  Created by hb on 30/10/26.
//

import Foundation


enum PresentationType {
    case slide, opacity, identy
}


/// Popup Model
struct PopupModel: @unchecked Sendable {
    var image: String?
    var title: String?
    var message: String
    var presentingType: PresentationType
    
    init(image: String? = nil, title: String? = nil, message: String, presentingType: PresentationType = .identy) {
        self.image = image
        self.title = title
        self.message = message
        self.presentingType = presentingType
    }
}
