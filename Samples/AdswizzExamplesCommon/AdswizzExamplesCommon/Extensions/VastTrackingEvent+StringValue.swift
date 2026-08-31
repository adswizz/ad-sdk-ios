//
//  VastTrackingEvent+StringValue.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension VastTrackingEvent {
    public var stringValue: String {
        switch self {
        case .mute: return "mute"
        case .unmute: return "unmute"
        case .pause: return "pause"
        case .resume: return "resume"
        case .rewind: return "rewind"
        case .skip: return "skip"
        case .playerExpand: return "playerExpand"
        case .playerCollapse: return "playerCollapse"
        case .notUsed: return "notUsed"
        case .loaded: return "loaded"
        case .start: return "start"
        case .firstQuartile: return "firstQuartile"
        case .midpoint: return "midpoint"
        case .thirdQuartile: return "thirdQuartile"
        case .complete: return "complete"
        case .progress: return "progress"
        case .closeLinear: return "closeLinear"
        case .creativeView: return "creativeView"
        case .acceptInvitation: return "acceptInvitation"
        case .adExpand: return "adExpand"
        case .adCollapse: return "adCollapse"
        case .minimize: return "minimize"
        case .close: return "close"
        case .overlayViewDuration: return "overlayViewDuration"
        case .otherAdInteraction: return "otherAdInteraction"
        case .unknown:
            fallthrough
        @unknown default:
            return "unknown"
        }
    }
}
