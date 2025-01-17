//
//  InactivityWatcher.swift
//  Inactivity
//
//  Created by Helio Tejedor on 7/5/21.
//

import Combine
import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public class InactivityWatcher: ObservableObject {
    @Published public private(set) var stateChanged: InactivityState = .inactive

    private var timer: AnyCancellable?
    private var lastTimeout: TimeInterval?

    public static let shared = InactivityWatcher()

    private init() {
        #if os(iOS)
        let uiAppClass = UIApplication.self
        let currentSendEvent = class_getInstanceMethod(uiAppClass, #selector(uiAppClass.sendEvent))
        let newSendEvent = class_getInstanceMethod(uiAppClass, #selector(uiAppClass.newSendEvent))
        method_exchangeImplementations(currentSendEvent!, newSendEvent!)
        print("sendEvent Swizzled")
        #elseif os(macOS)
        let uiAppClass = NSApplication.self
        let currentSendEvent = class_getInstanceMethod(uiAppClass, #selector(uiAppClass.sendEvent))
        let newSendEvent = class_getInstanceMethod(uiAppClass, #selector(uiAppClass.newSendEvent))
        method_exchangeImplementations(currentSendEvent!, newSendEvent!)
        print("sendEvent Swizzled")
        #endif
    }
    
    public func startWatch(timeout: TimeInterval) {
        timer?.cancel()
        if self.stateChanged != .active {
            self.stateChanged = .active
        }
        self.lastTimeout = timeout
        timer = Timer.publish(every: timeout, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                if self.stateChanged != .inactive {
                    self.stateChanged = .inactive
                }
                self.lastTimeout = nil
                self.timer?.cancel()
            }
    }

    public func inactivate() {
        if self.stateChanged != .inactive {
            self.stateChanged = .inactive
        }
        self.lastTimeout = nil
        self.timer?.cancel()
    }

    public func sendEvent() {
        if self.stateChanged == .active, let lastTimeout = self.lastTimeout {
            startWatch(timeout: lastTimeout)
        }
    }
}

