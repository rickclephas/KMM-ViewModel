//
//  TimeTravelViewModel.swift
//  KMMViewModelSample
//
//  Created by Rick Clephas on 28/11/2022.
//

import KMMViewModelSampleShared
import KMMViewModelCore

class TimeTravelViewModel: KMMViewModelSampleShared.TimeTravelViewModel {
    
    @Published var isResetDisabled: Bool = false
    
    override func resetTime() {
        isResetDisabled = !isResetDisabled
        guard isResetDisabled else { return }
        super.resetTime()
    }
}

@available(iOS 17.0, *)
extension KMMViewModelSampleShared.TimeTravelViewModel: Observable {
    public var observationRegistrar: ObservationRegistrar {
        \.actualTime
        \.travelEffect
        \.currentTime
        \.isFixedTime
    }
}
