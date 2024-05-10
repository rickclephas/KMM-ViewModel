//
//  ObservationRegistrar.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 25/03/2024.
//

import Foundation
import Observation
import Combine

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public class ObservationRegistrar {
    
    private let registrar = Observation.ObservationRegistrar()
    
    private let observableProperties: [ObservableProperty]
    private var properties: [NSObject:[ObservableProperty]] = [:]
    
    internal init(_ observableProperties: [ObservableProperty]) {
        self.observableProperties = observableProperties
    }
    
    private weak var observable: (any Observable)? = nil
    private var publisher: ObservableObjectPublisher? = nil
    
    internal func initialize(_ observable: any Observable, _ publisher: ObservableObjectPublisher) {
        observable.viewModelScope.setPropertyAccess(access)
        observable.viewModelScope.setPropertyWillSet(willSet)
        observable.viewModelScope.setPropertyDidSet(didSet)
        for observableProperty in observableProperties {
            Thread.current.threadDictionary["observableProperty"] = observableProperty
            observableProperty.initialize(subject: observable)
        }
        Thread.current.threadDictionary.removeObject(forKey: "observableProperty")
        self.observable = observable
        self.publisher = publisher
    }
    
    private func access(_ property: NSObject) {
        guard let observable else {
            if let observableProperty = Thread.current.threadDictionary["observableProperty"] as? ObservableProperty {
                var observableProperties = properties[property] ?? []
                observableProperties.append(observableProperty)
                properties[property] = observableProperties
            }
            return
        }
        guard let properties = properties[property] else { return }
        for property in properties {
            property.access(registrar: registrar, subject: observable)
        }
    }
    
    private func willSet(_ property: NSObject) {
        guard let observable, let properties = properties[property] else {
            publisher?.send()
            return
        }
        for property in properties {
            property.willSet(registrar: registrar, subject: observable)
        }
    }
    
    private func didSet(_ property: NSObject) {
        guard let observable, let properties = properties[property] else { return }
        for property in properties {
            property.didSet(registrar: registrar, subject: observable)
        }
    }
}

@resultBuilder
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ObservationRegistrarBuilder<ViewModel: Observable> {
    
    public static func buildExpression<Member>(_ expression: KeyPath<ViewModel, Member>) -> ObservableProperty {
        return expression
    }
    
    public static func buildBlock(_ components: ObservableProperty...) -> ObservationRegistrar {
        return ObservationRegistrar(components)
    }
}
