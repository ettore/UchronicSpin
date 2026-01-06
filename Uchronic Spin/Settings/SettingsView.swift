//
//  SettingsView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/30/25.
//

import SwiftData
import SwiftUI


struct SettingsView: View {
    let buildInteractor: BuildCollectionInteracting
    let presenter: SettingsPresenting
    @ObservedObject var state: SettingsState

    // this loads the username when the view is show on the screen
    // and watches the SwiftData db for changes
//    @Query var userData: [User]
//    var user: User? {
//        userData.first
//    }

    init(buildInteractor: BuildCollectionInteracting,
         presenter: SettingsPresenting,
         state: SettingsState) {
        self.buildInteractor = buildInteractor
        self.presenter = presenter
        self.state = state
    }

    var body: some View {
        NavigationStack {
            List {
                Text("Username: \(presenter.username)")

                Text("Number of items in collection: \(presenter.numberOfItemsInCollection)")

                Button("Re-Fetch User Metadata") {
                    Task {
                        await buildInteractor.fetchUserMetadataIfNeeded(cachePolicy: .cacheIgnore)
                    }
                }

                Button("Re-Fetch Collection") {
                    Task {
                        await buildInteractor.fetchCollectionIfNeeded(cachePolicy: .cacheIgnore)
                    }
                }

                Button("Delete Data") {
                    Task {
                        await buildInteractor.deleteAllUserData()
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

