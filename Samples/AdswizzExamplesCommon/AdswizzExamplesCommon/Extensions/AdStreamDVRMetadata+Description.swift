//
//  AdStreamDVRMetadata+Description.swift
//  AdswizzExamplesCommon
//
//  Created by George Mihoc on 09.06.2026.
//

import AdswizzSDK

extension AdStreamDVRMetadata {
    public var dvrDescription: String {
        """
        Start = \(self.start)
        End = \(self.end)
        Buffer = \(self.length)
        Metadata = \(self.metadata)
        """
    }
}
