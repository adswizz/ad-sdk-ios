//
//  SpeechRecognizerImpl.swift
//  AdswizzSDKPrivacyDataSpeech
//
//  Created by Teodor Cristea on 22.05.2024.
//  Copyright © 2024 AdsWizz, inc. All rights reserved.
//

import Foundation
import AdswizzSDKPrivacyDataCore
import Speech

@objc class SpeechRecognizerImpl: NSObject, SpeechRecognizer {
    let recognizer: SFSpeechRecognizer

    required init?(locale: Locale) {
        guard let recognizer = SFSpeechRecognizer(locale: locale) else {
            return nil
        }
        self.recognizer = recognizer
        super.init()
    }
    
    func recognitionTask(with request: SFSpeechRecognitionRequest, resultHandler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void) -> SFSpeechRecognitionTask {
        return recognizer.recognitionTask(with: request, resultHandler: resultHandler)
    }
}
