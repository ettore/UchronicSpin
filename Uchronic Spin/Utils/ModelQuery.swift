//
//  ModelQuery.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//

import Foundation
import SwiftData
import Combine


/// A property wrapper that keeps results of a `FetchDescriptor` in sync
/// with a `ModelContext`, similar to SwiftUI's `@Query` but usable
/// in regular classes.
@MainActor
@propertyWrapper
final class ModelQuery<Result: PersistentModel>: ObservableObject {
    @Published private(set) var wrappedValue: [Result] = []

    private let context: ModelContext
    private let descriptor: FetchDescriptor<Result>
    private var cancellable: AnyCancellable?

    convenience init(context: ModelContext) {
        self.init(context: context, descriptor: FetchDescriptor<Result>())
    }

    init(context: ModelContext, descriptor: FetchDescriptor<Result>) {
        self.context = context
        self.descriptor = descriptor
        reload()

        // Observe context saves and refresh
        cancellable = NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: context
        )
        .sink { [weak self] _ in
            self?.reload()
        }
    }

    func reload() {
        do {
            wrappedValue = try context.fetch(descriptor)
        } catch {
            print("ModelQuery fetch error: \(error)")
            wrappedValue = []
        }
    }
}
