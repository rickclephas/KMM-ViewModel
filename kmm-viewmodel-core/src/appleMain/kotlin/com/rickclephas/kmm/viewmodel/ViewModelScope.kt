package com.rickclephas.kmm.viewmodel

import com.rickclephas.kmm.viewmodel.objc.KMMVMViewModelScopeProtocol
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import platform.darwin.NSObject
import kotlin.experimental.ExperimentalNativeApi
import kotlin.native.ref.WeakReference

/**
 * Holds the [CoroutineScope] of a [KMMViewModel].
 * @see coroutineScope
 */
public actual typealias ViewModelScope = KMMVMViewModelScopeProtocol

/**
 * Gets the [CoroutineScope] associated with the [KMMViewModel] of `this` [ViewModelScope].
 */
public actual val ViewModelScope.coroutineScope: CoroutineScope
    get() = asImpl().coroutineScope

/**
 * Casts `this` [ViewModelScope] to a [ViewModelScopeImpl].
 */
@InternalKMMViewModelApi
public inline fun ViewModelScope.asImpl(): ViewModelScopeImpl = this as ViewModelScopeImpl

/**
 * Implementation of [ViewModelScope].
 */
@OptIn(ExperimentalNativeApi::class)
@InternalKMMViewModelApi
public class ViewModelScopeImpl internal constructor(
    private val viewModelRef: WeakReference<KMMViewModel>
): NSObject(), ViewModelScope {

    /**
     * The [CoroutineScope] associated with the [KMMViewModel].
     */
    public val coroutineScope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private val _subscriptionCount = MutableStateFlow(0)
    /**
     * A [StateFlow] that emits the number of subscribers to the [KMMViewModel].
     */
    public val subscriptionCount: StateFlow<Int> = _subscriptionCount.asStateFlow()

    override fun increaseSubscriptionCount() {
        _subscriptionCount.update { it + 1 }
    }

    override fun decreaseSubscriptionCount() {
        _subscriptionCount.update { it - 1 }
    }

    private var propertyAccess: ((NSObject) -> Unit)? = null

    override fun setPropertyAccess(propertyAccess: (NSObject?) -> Unit) {
        if (this.propertyAccess != null) {
            throw IllegalStateException("KMMViewModel can't be wrapped more than once")
        }
        this.propertyAccess = propertyAccess
    }

    /**
     * Invokes the listener set by [setPropertyAccess].
     */
    public fun propertyAccess(property: Any) {
        propertyAccess?.invoke(property as NSObject)
    }

    private var propertyWillSet: ((NSObject) -> Unit)? = null

    override fun setPropertyWillSet(propertyWillSet: (NSObject?) -> Unit) {
        if (this.propertyWillSet != null) {
            throw IllegalStateException("KMMViewModel can't be wrapped more than once")
        }
        this.propertyWillSet = propertyWillSet
    }

    /**
     * Invokes the listener set by [setPropertyWillSet].
     */
    public fun propertyWillSet(property: Any) {
        propertyWillSet?.invoke(property as NSObject)
    }

    private var propertyDidSet: ((NSObject) -> Unit)? = null

    override fun setPropertyDidSet(propertyDidSet: (NSObject?) -> Unit) {
        if (this.propertyDidSet != null) {
            throw IllegalStateException("KMMViewModel can't be wrapped more than once")
        }
        this.propertyDidSet = propertyDidSet
    }

    /**
     * Invokes the listener set by [setPropertyDidSet].
     */
    public fun propertyDidSet(property: Any) {
        propertyDidSet?.invoke(property as NSObject)
    }

    override fun cancel() {
        coroutineScope.cancel()
        viewModelRef.value?.onCleared()
    }
}
