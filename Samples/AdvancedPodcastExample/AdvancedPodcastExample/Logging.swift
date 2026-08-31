//
//  Logging.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 29.08.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import Foundation
import XCGLogger
import AdswizzSDKCore

let adswizzSDKName: String = "AdswizzSDK"

extension XCGLogger {
    func configure() {
        // Create a destination for the system console log (via NSLog)
        let systemDestination = MultiLineSplitAppleSystemLogDestination(identifier: "advancedLogger.systemDestination")

        // Optionally set some configuration options
        systemDestination.outputLevel = .verbose
        systemDestination.showLogIdentifier = false
        systemDestination.showFunctionName = true
        systemDestination.showThreadName = true
        systemDestination.showLevel = true
        systemDestination.showFileName = true
        systemDestination.showLineNumber = true
        systemDestination.showDate = true
        systemDestination.formatters = [AdswizzSDKFormatter()]

        // Add the destination to the logger
        add(destination: systemDestination)
        
        if let logFile = FileManager.documentFilePathFor("app.logs") {
            let fileDestination = FileDestination(writeToFile: logFile.path, identifier: "advancedLogger.fileDestination")

            // Optionally set some configuration options
            fileDestination.outputLevel = .verbose
            fileDestination.showLogIdentifier = false
            fileDestination.showFunctionName = true
            fileDestination.showThreadName = true
            fileDestination.showLevel = true
            fileDestination.showFileName = true
            fileDestination.showLineNumber = true
            fileDestination.showDate = true
            fileDestination.formatters = [AdswizzSDKFormatter()]

            // Process this destination in the background
            fileDestination.logQueue = XCGLogger.logQueue

            // Add the destination to the logger
            add(destination: fileDestination)
        }

////
//        if let fileDestination: FileDestination = destination(withIdentifier: "advancedLogger.fileDestination") as? FileDestination {
//            let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
//            ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
//            ansiColorLogFormatter.colorize(level: .debug, with: .black)
//            ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
//            ansiColorLogFormatter.colorize(level: .notice, with: .green, options: [.italic])
//            ansiColorLogFormatter.colorize(level: .warning, with: .red, options: [.faint])
//            ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
//            ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
//            ansiColorLogFormatter.colorize(level: .alert, with: .white, on: .red, options: [.bold])
//            ansiColorLogFormatter.colorize(level: .emergency, with: .white, on: .red, options: [.bold, .blink])
//            fileDestination.formatters = [ansiColorLogFormatter]
//        }
    }
}


class MultiLineSplitAppleSystemLogDestination: AppleSystemLogDestination {

    override func process(logDetails: LogDetails) {
        if owner == nil { return }

        let preambul = extendedDetails(from: logDetails)
        if preambul.count + logDetails.message.count > 1000 {
            output(logDetails: logDetails, message: "")
            NSLog("********BEGIN MULTILINE***********")
            logDetails.message.split(by: 1000).forEach {
                NSLog("[MULTILINE]\n%@", $0)
            }
            NSLog("********END MULTILINE***********")
        } else {
            output(logDetails: logDetails, message: "\(preambul)> \(logDetails.message)")
        }
    }
    
    private func extendedDetails(from logDetails: LogDetails) -> String {
        guard let owner = owner else { return "" }
        var extendedDetails: String = ""
        
        if showDate {
            extendedDetails += "\((owner.dateFormatter != nil) ? owner.dateFormatter!.string(from: logDetails.date) : logDetails.date.description) "
        }
        
        if showLevel {
            extendedDetails += "[\(levelDescriptions[logDetails.level] ?? owner.levelDescriptions[logDetails.level] ?? logDetails.level.description)] "
        }
        
        if showLogIdentifier {
            extendedDetails += "[\(owner.identifier)] "
        }
        
        if showThreadName {
            if Thread.isMainThread {
                extendedDetails += "[main] "
            }
            else {
                if let threadName = Thread.current.name, !threadName.isEmpty {
                    extendedDetails += "[\(threadName)] "
                }
                else if let queueName = DispatchQueue.currentQueueLabel, !queueName.isEmpty {
                    extendedDetails += "[\(queueName)] "
                }
                else {
                    extendedDetails += String(format: "[%p] ", Thread.current)
                }
            }
        }
        
        if showFileName {
            extendedDetails += "[\((logDetails.fileName as NSString).lastPathComponent)\((showLineNumber ? ":" + String(logDetails.lineNumber) : ""))] "
        }
        else if showLineNumber {
            extendedDetails += "[\(logDetails.lineNumber)] "
        }
        
        if showFunctionName {
            extendedDetails += "\(logDetails.functionName) "
        }
        return extendedDetails
    }
}

class AdswizzSDKFormatter: LogFormatterProtocol {
    var debugDescription: String {
        return "AdswizzSDKFormatter"
    }
    
    func format(logDetails: inout LogDetails, message: inout String) -> String {
        if let info = logDetails.userInfo[XCGLogger.Constants.userInfoKeyTags] as? String, info == adswizzSDKName {
            message = "[\(adswizzSDKName)] \(message)"
        }
        return message
    }
}

extension XCGLogger: @retroactive AdLoggerDestination {
    public func log(_ level: AdLogger.Level, functionName: String, fileName: String, lineNumber: Int, line: String) {
        switch level {
        case .verbose:
            logln(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: [XCGLogger.Constants.userInfoKeyTags: "\(adswizzSDKName)"]) {
                return line
            }
        case .debug:
            logln(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: [XCGLogger.Constants.userInfoKeyTags: "\(adswizzSDKName)"]) {
                return line
            }
        case .info:
            logln(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: [XCGLogger.Constants.userInfoKeyTags: "\(adswizzSDKName)"]) {
                return line
            }
        case .error:
            logln(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: [XCGLogger.Constants.userInfoKeyTags: "\(adswizzSDKName)"]) {
                return line
            }
        case .none:
            break
        @unknown default:
            break
        }
    }
}

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            var endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            var shouldSkipCRLF = false
            if let result = self.range(of: "\n", options: [.backwards], range: Range(uncheckedBounds: (startIndex, endIndex)), locale: nil) {
                endIndex = result.upperBound
                endIndex = self.index(before: endIndex)
                shouldSkipCRLF = true
            }
            results.append(self[startIndex..<endIndex])
            startIndex = shouldSkipCRLF ? self.index(after: endIndex) : endIndex
        }
        
        return results.map { String($0) }
    }
}

extension FileManager {
    static func documentFilePathFor(_ fileName: String) -> URL? {
        let fileManager = FileManager.default
        var filePath = try? fileManager.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: false)
        filePath?.appendPathComponent(fileName)
        return filePath
    }
}
