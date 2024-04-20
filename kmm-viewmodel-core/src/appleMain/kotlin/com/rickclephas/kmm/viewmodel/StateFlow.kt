package com.rickclephas.kmm.viewmodel

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

/**
 * @see kotlinx.coroutines.flow.MutableStateFlow
 */
public actual fun <T> MutableStateFlow(
    viewModelScope: ViewModelScope,
    value: T
): MutableStateFlow<T> = MutableStateFlowImpl(viewModelScope.asImpl(), MutableStateFlow(value))

/**
 * A [MutableStateFlow] that triggers [ViewModelScopeImpl.propertyWillSet],
 * [ViewModelScopeImpl.propertyDidSet] and [ViewModelScopeImpl.propertyAccess]
 * and accounts for the [ViewModelScopeImpl.subscriptionCount].
 */
private class MutableStateFlowImpl<T>(
    private val viewModelScope: ViewModelScopeImpl,
    private val stateFlow: MutableStateFlow<T>
): MutableStateFlow<T> {

    override var value: T
        get() {
            viewModelScope.propertyAccess(this)
            return stateFlow.value
        }
        set(value) {
            val changed = stateFlow.value != value
            if (changed) viewModelScope.propertyWillSet(this)
            stateFlow.value = value
            if (changed) viewModelScope.propertyDidSet(this)
        }

    override val replayCache: List<T> get() {
        viewModelScope.propertyAccess(this)
        return stateFlow.replayCache
    }

    override val subscriptionCount: StateFlow<Int> =
        SubscriptionCountFlow(viewModelScope.subscriptionCount, stateFlow.subscriptionCount)

    override suspend fun collect(collector: FlowCollector<T>): Nothing =
        stateFlow.collect(collector)

    override fun compareAndSet(expect: T, update: T): Boolean {
        val changed = stateFlow.value == expect && expect != update
        if (changed) viewModelScope.propertyWillSet(this)
        val result = stateFlow.compareAndSet(expect, update)
        if (changed) viewModelScope.propertyDidSet(this)
        return result
    }

    @ExperimentalCoroutinesApi
    override fun resetReplayCache() = stateFlow.resetReplayCache()

    // Same implementation as in StateFlowImpl, but we need to go through our own value property.
    // https://github.com/Kotlin/kotlinx.coroutines/blob/6dfabf763fe9fc91fbb73eb0f2d5b488f53043f1/kotlinx-coroutines-core/common/src/flow/StateFlow.kt#L369
    override fun tryEmit(value: T): Boolean {
        this.value = value
        return true
    }

    // Same implementation as in StateFlowImpl, but we need to go through our own value property.
    // https://github.com/Kotlin/kotlinx.coroutines/blob/6dfabf763fe9fc91fbb73eb0f2d5b488f53043f1/kotlinx-coroutines-core/common/src/flow/StateFlow.kt#L374
    override suspend fun emit(value: T) {
        this.value = value
    }
}

/**
 * A [StateFlow] that combines the subscription counts of a [ViewModelScopeImpl] and [StateFlow].
 */
private class SubscriptionCountFlow(
    private val viewModelScopeSubscriptionCount: StateFlow<Int>,
    private val stateFlowSubscriptionCount: StateFlow<Int>
): StateFlow<Int> {
    override val value: Int
        get() = viewModelScopeSubscriptionCount.value + stateFlowSubscriptionCount.value

    override val replayCache: List<Int>
        get() = listOf(value)

    override suspend fun collect(collector: FlowCollector<Int>): Nothing {
        viewModelScopeSubscriptionCount.combine(stateFlowSubscriptionCount) { count1, count2 ->
            count1 + count2
        }.collect(collector)
        throw IllegalStateException("SubscriptionCountFlow collect completed")
    }
}

/**
 * @see kotlinx.coroutines.flow.stateIn
 */
public actual fun <T> Flow<T>.stateIn(
    viewModelScope: ViewModelScope,
    coroutineContext: CoroutineContext,
    started: SharingStarted,
    initialValue: T
): StateFlow<T> {
    // Similar to kotlinx.coroutines, but using our custom MutableStateFlowImpl and CoroutineContext logic.
    // https://github.com/Kotlin/kotlinx.coroutines/blob/6dfabf763fe9fc91fbb73eb0f2d5b488f53043f1/kotlinx-coroutines-core/common/src/flow/operators/Share.kt#L135
    val scope = viewModelScope.asImpl()
    val upstream = flowOn(coroutineContext)
    val state = MutableStateFlowImpl(scope, MutableStateFlow(initialValue))
    val job = scope.coroutineScope.launchSharing(EmptyCoroutineContext, upstream, state, started, initialValue)
    return ReadonlyStateFlow(state, job)
}

/**
 * Identical to the kotlinx.coroutines implementation, but without the SharedFlow logic.
 * https://github.com/Kotlin/kotlinx.coroutines/blob/6dfabf763fe9fc91fbb73eb0f2d5b488f53043f1/kotlinx-coroutines-core/common/src/flow/operators/Share.kt#L194
 */
private fun <T> CoroutineScope.launchSharing(
    context: CoroutineContext,
    upstream: Flow<T>,
    shared: MutableSharedFlow<T>,
    started: SharingStarted,
    initialValue: T
): Job {
    val start = if (started == SharingStarted.Eagerly) CoroutineStart.DEFAULT else CoroutineStart.UNDISPATCHED
    return launch(context, start = start) {
        when {
            started === SharingStarted.Eagerly -> {
                upstream.collect(shared)
            }
            started === SharingStarted.Lazily -> {
                shared.subscriptionCount.first { it > 0 }
                upstream.collect(shared)
            }
            else -> started.command(shared.subscriptionCount)
                .distinctUntilChanged()
                .collectLatest {
                    when (it) {
                        SharingCommand.START -> upstream.collect(shared)
                        SharingCommand.STOP -> { }
                        SharingCommand.STOP_AND_RESET_REPLAY_CACHE -> shared.tryEmit(initialValue)
                    }
                }
        }
    }
}

/**
 * Similar to the kotlinx.coroutines implementation, used to return a read-only StateFlow with an optional Job.
 * https://github.com/Kotlin/kotlinx.coroutines/blob/6dfabf763fe9fc91fbb73eb0f2d5b488f53043f1/kotlinx-coroutines-core/common/src/flow/operators/Share.kt#L379
 */
private class ReadonlyStateFlow<T>(
    flow: StateFlow<T>,
    @Suppress("unused")
    private val job: Job?
): StateFlow<T> by flow
