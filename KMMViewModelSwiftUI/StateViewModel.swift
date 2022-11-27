//
//  StateViewModel.swift
//  KMMViewModelSwiftUI
//
//  Created by Rick Clephas on 27/11/2022.
//

import SwiftUI
import KMMViewModelCore

/// A `StateObject` property wrapper for `KMMViewModel`s.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper
public struct StateViewModel<ViewModel>: DynamicProperty {
    
    @StateObject private var observableObject: ObservableViewModel<ViewModel>
    
    /// The underlying `KMMViewModel` referenced by the `StateViewModel`.
    public var wrappedValue: ViewModel { observableObject.viewModel }
    
    /// A projection of the observed `KMMViewModel` that creates bindings to its properties using dynamic member lookup.
    public lazy var projectedValue: ObservableViewModel<ViewModel>.Projection = {
        ObservableViewModel.Projection(observableObject)
    }()
    
    internal init(observableObject: @autoclosure @escaping () -> ObservableViewModel<ViewModel>) {
        self._observableObject = SwiftUI.StateObject(wrappedValue: observableObject())
    }
    
    /// Creates a `StateViewModel` for the specified `KMMViewModel`.
    /// - Parameters:
    ///     - wrappedValue: The `KMMViewModel` to observe.
    ///     - keyPath: The key path to the `ViewModelScope` property of the ViewModel.
    public init(
        wrappedValue: @autoclosure @escaping () -> ViewModel,
        _ keyPath: KeyPath<ViewModel, ViewModelScope>
    ) {
        self.init(observableObject: createObservableViewModel(for: wrappedValue(), with: keyPath))
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension StateViewModel {
    /// Creates a `StateViewModel` for the specified `KMMViewModel` projection.
    init(wrappedValue: ObservableViewModel<ViewModel>.Projection) {
        self.init(observableObject: wrappedValue.observableObject)
    }
}