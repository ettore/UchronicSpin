//
//  MainView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/20/25.
//


import SwiftUI


struct MainView: View {
    var body: some View {
        Color.green
            .ignoresSafeArea()
            .overlay(
                Button("Sign Out") {
                    Task {
                        uchronicSignOut()
                    }
                }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
            )
    }
}
