//
//  ObservableProperty.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 25/03/2024.
//

import Observation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public protocol ObservableProperty<ViewModel> {
    associatedtype ViewModel: Observable
    
    func willSet(registrar: ObservationRegistrar, viewModel: ViewModel)
    
    func didSet(registrar: ObservationRegistrar, viewModel: ViewModel)
    
    func access(registrar: ObservationRegistrar, viewModel: ViewModel)
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension KeyPath: ObservableProperty where Root: Observable {
    public typealias ViewModel = Root
    
    public func willSet(registrar: ObservationRegistrar, viewModel: ViewModel) {
        registrar.willSet(viewModel, keyPath: self)
    }

    public func didSet(registrar: ObservationRegistrar, viewModel: ViewModel) {
        registrar.didSet(viewModel, keyPath: self)
    }
    
    public func access(registrar: ObservationRegistrar, viewModel: ViewModel) {
        registrar.access(viewModel, keyPath: self)
    }
}
