//
//  ObservableViewModel.swift
//  KMMViewModelCore
//
//  Created by Rick Clephas on 27/11/2022.
//

import Combine

/// Creates an `ObservableObject` for the specified `KMMViewModel`.
/// - Parameters:
///     - viewModel: The `KMMViewModel` to wrap in an `ObservableObject`.
///     - keyPath: The key path to the `ViewModelScope` property of the ViewModel.
public func createObservableViewModel<ViewModel>(
    for viewModel: ViewModel,
    with keyPath: KeyPath<ViewModel, ViewModelScope>
) -> ObservableViewModel<ViewModel> {
    ObservableViewModel(viewModel, keyPath)
}

/// An `ObservableObject` for a `KMMViewModel`.
public final class ObservableViewModel<ViewModel>: ObservableObject {
    
    public let objectWillChange: ObservableViewModelPublisher
    
    private var _viewModel: ViewModel
    public var viewModel: ViewModel { _viewModel }
    
    internal init(_ viewModel: ViewModel, _ keyPath: KeyPath<ViewModel, ViewModelScope>) {
        objectWillChange = ObservableViewModelPublisher(viewModel[keyPath: keyPath])
        self._viewModel = viewModel
    }
    
    public func get<T>(_ keyPath: KeyPath<ViewModel, T>) -> T {
        _viewModel[keyPath: keyPath]
    }
    
    public func set<T>(_ keyPath: WritableKeyPath<ViewModel, T>, to newValue: T) {
        _viewModel[keyPath: keyPath] = newValue
    }
}

/// Publisher for `ObservableViewModel` that connects to the `ViewModelScope`.
public final class ObservableViewModelPublisher: Publisher {
    public typealias Output = Void
    public typealias Failure = Never
    
    internal weak var viewModelScope: ViewModelScope?
    
    private let publisher = ObservableObjectPublisher()
    
    init(_ viewModelScope: ViewModelScope) {
        self.viewModelScope = viewModelScope
        viewModelScope.setSendObjectWillChange { [weak self] in
            self?.publisher.send()
        }
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
        viewModelScope?.increaseSubscriptionCount()
        publisher.receive(subscriber: ObservableViewModelSubscriber(self, subscriber))
    }
    
    deinit {
        viewModelScope?.cancel()
    }
}

/// Subscriber for `ObservableViewModelPublisher` that creates `ObservableViewModelSubscription`s.
private class ObservableViewModelSubscriber<S>: Subscriber where S : Subscriber, Never == S.Failure, Void == S.Input {
    typealias Input = Void
    typealias Failure = Never
    
    private let publisher: ObservableViewModelPublisher
    private let subscriber: S
    
    init(_ publisher: ObservableViewModelPublisher, _ subscriber: S) {
        self.publisher = publisher
        self.subscriber = subscriber
    }
    
    func receive(subscription: Subscription) {
        subscriber.receive(subscription: ObservableViewModelSubscription(publisher, subscription))
    }
    
    func receive(_ input: Void) -> Subscribers.Demand {
        subscriber.receive(input)
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        subscriber.receive(completion: completion)
    }
}

/// Subscription for `ObservableViewModelPublisher` that decreases the subscription count upon cancellation.
private class ObservableViewModelSubscription: Subscription {
    
    private let publisher: ObservableViewModelPublisher
    private let subscription: Subscription
    
    init(_ publisher: ObservableViewModelPublisher, _ subscription: Subscription) {
        self.publisher = publisher
        self.subscription = subscription
    }
    
    func request(_ demand: Subscribers.Demand) {
        subscription.request(demand)
    }
    
    private var cancelled = false
    
    func cancel() {
        subscription.cancel()
        guard !cancelled else { return }
        cancelled = true
        publisher.viewModelScope?.decreaseSubscriptionCount()
    }
}