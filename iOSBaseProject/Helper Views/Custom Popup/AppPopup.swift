//
//  AppPopup.swift
//  FreshMorning
//
//  Created by hb on 30/10/26.
//

import SwiftUI


/// Popup Enum
@MainActor
enum AppPopUp {
    
    static func show(_ model: PopupModel) {
        PopupCenter.shared.show {
            Popup(model: model)
        }
    }
    
    /// For different types of popup create different static methods here.
    
    static func dismiss() {
        PopupCenter.shared.dismiss()
    }
}


struct Popup: View {

    let model: PopupModel

    @State private var isPresented = false

    var body: some View {
        ZStack {
            Color.black
                .opacity(isPresented ? 0.4 : 0)
                .ignoresSafeArea()
            
            if isPresented {
                popupContent
                    .compositingGroup()
                    .transition(popupTransition)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = true
            }
        }
    }

    private var popupContent: some View {
        VStack(spacing: 15) {

            if let image = model.image {
                Image(systemName: image)
                    .font(.largeTitle)
            }

            if let title = model.title {
                Text(title)
                    .font(.title2.bold())
            }

            Text(model.message)
            
            HStack {
                Button {
                    dismissPopup()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color(hex: "#CBD5E1"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                Button {
                    dismissPopup()
                } label: {
                    Text("Okay")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color(hex: "#CBD5E1"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

            }
        }
        .padding(24)
        .frame(maxWidth: 320)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var popupTransition: AnyTransition {
        switch model.presentingType {
        case .slide:
            return .move(edge: .leading)

        case .opacity:
            return .opacity

        case .identy:
//            return .asymmetric(
//                insertion: .scale(scale: 0, anchor: .center),
//                removal: .opacity
//            )
            
                return .scale(scale: 0, anchor: .center)
        }
    }
    
    private func dismissPopup() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            AppPopUp.dismiss()
        }
    }
}

#Preview {
    Popup(model: PopupModel(
        image: "checkmark.circle.fill",
        title: "Success",
        message: "Your transaction was successful.",
        presentingType: .slide
    ))
}


// Usage :
//                AppPopUp.show(
//                    PopupModel(
//                        image: "checkmark.circle.fill",
//                        title: "Success",
//                        message: "Your transaction was successful.",
//                        presentingType: .slide
//                    )
//                )
                
