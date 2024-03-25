//
//  Observable.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 25/03/2024.
//

import Foundation
import Observation
import KMMViewModelCoreObjC

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public protocol Observable: Observation.Observable {
    associatedtype ViewModel: Observable
    
    @ViewModelObservationRegistrarBuilder<ViewModel>
    var viewModelObservationRegistrar: ViewModelObservationRegistrar<ViewModel> { get }
}
