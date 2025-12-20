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
                        .setUpStateIfNeeded(with: modelContext)
                    let presenter = SettingsPresenter(state: state)
                    SettingsView(buildInteractor: buildInteractor,
                                 presenter: presenter,
                                 state: state)
                }
            }
            .onFirstWillAppear {
                // note: ".task" is not run everytime SwiftUI recreates the
                // View struct or the body is recomputed. However it IS run
                // when the view is added to the hierarchy and when the
                // view disappears and reappears.

                // Loads data from SwiftData storage (or from network if needed)
                // and set up state objects; we have to do so here instead than
                // the initializer because `modelContext` is not yet ready at
                // init time.
                await buildInteractor.loadCollection(with: modelContext)
            }
        }
    }
}

#Preview {
    MainView(apiService: APIService())
}
