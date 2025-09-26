//
//  MainView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/20/25.
//


import SwiftUI


struct MainView: View {
    private let apiService: API
    let buildInteractor: BuildCollectionInteractor

    init(apiService: API) {
        self.apiService = apiService
        buildInteractor = BuildCollectionInteractor(apiService: apiService)
    }

    var body: some View {
        Color.green
            .ignoresSafeArea()
            .overlay(
                VStack {
                    Button("Fetch Collection") {
                        Task {
                            let num = await buildInteractor.fetchNumberOfItems()
                            print("Number of items: \(num)")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button("Sign Out") {
                        Task {
                            uchronicSignOut()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            )
    }
}

#Preview {
    MainView(apiService: APIService())
}
