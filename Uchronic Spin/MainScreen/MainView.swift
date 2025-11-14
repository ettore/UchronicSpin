//
//  MainView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/20/25.
//

import SwiftUI


/// The "root" view for the main screen of the app that displays the
/// user's collection and search UI.
///
/// When this view is first displayed and there's no user's metadata or collection
/// on disk, it should automatically fetch it and display it.
struct MainView: View {
    @Environment(\.modelContext) var modelContext
    private let apiService: API
    private var buildInteractor: BuildCollectionInteracting

    init(apiService: API) {
        self.apiService = apiService
        buildInteractor = BuildCollectionInteractor(apiService: apiService)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Text("Collection")
            }
            .navigationTitle("Uchronic Spin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink("Settings") {
                    let state = buildInteractor
                        .configureStateIfNeeded(with: modelContext)
                    SettingsView(buildInteractor: buildInteractor,
                                 state: state)
                }
            }
            .onFirstWillAppear {
                // note: ".task" is not run everytime SwiftUI recreates the
                // View struct or the body is recomputed. However it IS run
                // when the view is added to the hierarchy and when the
                // view disappears and reappears.
                // We have to create the state here because `modelContext` is
                // not yet ready at init time.
                buildInteractor
                    .configureSettingsState(with: modelContext)
                await buildInteractor.fetchUserMetadata()
            }
        }
    }
}

#Preview {
    MainView(apiService: APIService())
}
