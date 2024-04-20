//
//  ObservableProperty.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 25/03/2024.
//

import Observation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public protocol ObservableProperty {
    
    func initialize(subject: any Observable)
    
    func willSet(registrar: Observation.ObservationRegistrar, subject: any Observable)
    
    func didSet(registrar: Observation.ObservationRegistrar, subject: any Observable)
    
    func access(registrar: Observation.ObservationRegistrar, subject: any Observable)
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension KeyPath: ObservableProperty where Root: Observable {
    
    private func root(_ subject: any Observable) -> Root {
        guard let root = subject as? Root else {
            fatalError("subject must be of type Root")
        }
        return root
    }
    
    public func initialize(subject: any Observable) {
        _  = root(subject)[keyPath: self]
    }
    
    public func willSet(registrar: Observation.ObservationRegistrar, subject: any Observable) {
        registrar.willSet(root(subject), keyPath: self)
    }

    public func didSet(registrar: Observation.ObservationRegistrar, subject: any Observable) {
        registrar.didSet(root(subject), keyPath: self)
    }
    
    public func access(registrar: Observation.ObservationRegistrar, subject: any Observable) {
        registrar.access(root(subject), keyPath: self)
    }
}
