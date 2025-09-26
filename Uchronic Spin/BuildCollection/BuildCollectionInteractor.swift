//
//  BuildCollectionInteractor.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 9/23/25.
//

import Foundation


protocol BuildCollectionInteracting: Sendable {
    var apiService: CollectionAPI {get}

    func fetchNumberOfItems() async -> Int
}

/// This state object describe the state of the collection, whether it has
/// been loaded entirely or not, if an error occurred, etc.
final class CollectionState: ObservableObject {
    @Published var numberOfItems: Int = 0
    @Published var error: Error?
    @Published var hasLoadedWholeCollection = false

    var hasError: Bool {
        get {
            error != nil
        }

        // need an explicit setter to bind to this property in SwiftUI
        set {
            if !newValue {
                error = nil
            }
        }
    }
}

@MainActor
class BuildCollectionInteractor: BuildCollectionInteracting {
    let apiService: CollectionAPI
    private let state: CollectionState

    init(apiService: CollectionAPI) {
        self.apiService = apiService
        self.state = CollectionState()
    }

    func fetchNumberOfItems() async -> Int {
        do {
            state.numberOfItems = try await apiService.getNumberOfItems()
            return state.numberOfItems
        } catch {
            print(error)
            state.error = error
            return 0
        }
    }
}
