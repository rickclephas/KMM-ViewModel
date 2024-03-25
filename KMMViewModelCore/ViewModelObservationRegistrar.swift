//
//  ViewModelObservationRegistrar.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 25/03/2024.
//

import Foundation
import Observation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ViewModelObservationRegistrar<ViewModel: Observable> {
    
    private let registrar = ObservationRegistrar()
    
    private let properties: [NSObject:[any ObservableProperty<ViewModel>]]
    
    internal init(properties: [any ObservableProperty<ViewModel>]) {
        self.properties = [:] // TODO: store and map properties
    }
    
    internal func willSet(_ viewModel: ViewModel, property: NSObject) -> Bool {
        guard let properties = properties[property] else { return false }
        for property in properties {
            property.willSet(registrar: registrar, viewModel: viewModel)
        }
        return true
    }
    
    internal func didSet(_ viewModel: ViewModel, property: NSObject) -> Bool {
        guard let properties = properties[property] else { return false }
        for property in properties {
            property.didSet(registrar: registrar, viewModel: viewModel)
        }
        return true
    }
    
    internal func access(_ viewModel: ViewModel, property: NSObject) -> Bool {
        guard let properties = properties[property] else { return false }
        for property in properties {
            property.access(registrar: registrar, viewModel: viewModel)
        }
        return true
    }
}

@resultBuilder
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ViewModelObservationRegistrarBuilder<ViewModel: Observable> {
    public static func buildExpression<Member>(_ expression: KeyPath<ViewModel, Member>) -> any ObservableProperty<ViewModel> {
        return expression
    }
    
    public static func buildBlock(_ components: any ObservableProperty<ViewModel>...) -> ViewModelObservationRegistrar<ViewModel> {
        return ViewModelObservationRegistrar(properties: components)
    }
}
