//
//  OTPViewModifier.swift
//  FreshMorning
//
//  Created by hb on 01/10/26.
//

import Foundation
import SwiftUI

struct OTPModifier: ViewModifier {
    var isFocused: Bool
    var isFilled: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                isFilled ? Color.white : Color.gray.opacity(0.4)
            )
            .overlay {
                Circle()
                    .strokeBorder(
                        (isFocused || isFilled) ? Color.green : Color.gray.opacity(0.8),
                        lineWidth: 2
                    )
            }
            .clipShape(Circle())
    }
}



/*
 struct ContentView: View {

     @State private var showExporter = false

     var body: some View {
         Button("Save File") {
             showExporter = true
         }
         .fileExporter(
             isPresented: $showExporter,
             document: MyDocument(),
             contentType: .text,
             defaultFilename: "MyFile"
         ) { result in
             switch result {
             case .success(let url):
                 print("Saved at:", url)

             case .failure(let error):
                 print("Save failed:", error)
             }
         }
     }
 }
 */
