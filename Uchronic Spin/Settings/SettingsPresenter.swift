//
//  SettingsPresenter.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//

import Foundation


@MainActor
protocol SettingsPresenting {
    var numberOfItemsInCollection: String {get}
    var username: String {get}
}


/// Presentation logic for Settings.
class SettingsPresenter: SettingsPresenting {
    private let state: SettingsState

    init(state: SettingsState) {
        self.state = state
    }

    var numberOfItemsInCollection: String {
        state.user?.numberOfItems.formatted(.number.grouping(.never)) ?? ""
    }

    var username: String {
        state.user?.username ?? ""
    }
}
