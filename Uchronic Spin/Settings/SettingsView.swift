//
//  SettingsView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import SwiftData
import SwiftUI


struct SettingsView: View {
    let apiService: API
    let buildInteractor: BuildCollectionInteractor
    let presenter: SettingsPresenter
    @ObservedObject var state: SettingsState

    // this loads the username when the view is show on the screen
    // and watches the SwiftData db for changes
//    @Query var userData: [User]
//    var user: User? {
//        userData.first
//    }

    init(apiService: API, modelContext: ModelContext) {
        self.apiService = apiService
        self.buildInteractor = BuildCollectionInteractor(apiService: apiService,
                                                         modelContext: modelContext)
        self.presenter = SettingsPresenter(state: buildInteractor.state)
        self.state = buildInteractor.state
    }

    var body: some View {
        NavigationStack {
            List {
                Text("Username: \(presenter.username)")

                Text("Number of items in collection: \(presenter.numberOfItemsInCollection)")

                Button("Re-Fetch Collection") {
                    Task {
                        await buildInteractor.fetchUserMetadata()
                    }
                }

                Button("Sign Out") {
                    Task {
                        uchronicSignOut()
                    }
                }
                .tint(.red)
            }
            .navigationTitle("Settings")
        }
    }
}

