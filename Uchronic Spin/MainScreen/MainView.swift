//
//  MainView.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 5/20/25.
//

import SwiftUI


struct MainView: View {
    private let apiService: API
    @Environment(\.modelContext) var modelContext

    init(apiService: API) {
        self.apiService = apiService
    }

    var body: some View {
        NavigationStack {
            Color.purple
                .ignoresSafeArea()
                .navigationTitle("Uchronic Spin")
                .toolbar {
                    NavigationLink("Settings") {
                        SettingsView(apiService: apiService,
                                     modelContext: modelContext)
                    }
                    .tint(.white)
                }
        }
    }
}

#Preview {
    MainView(apiService: APIService())
}
