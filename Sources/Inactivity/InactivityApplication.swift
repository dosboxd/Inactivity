//
//  InactivityApplication.swift
//  Inactivity
//
//  Created by Helio Tejedor on 7/3/21.
//

#if os(iOS)
import UIKit

extension UIApplication {

    @objc dynamic func newSendEvent(_ event: UIEvent) {
        newSendEvent(event)
        InactivityWatcher.shared.sendEvent()
    }

}
#elseif os(macOS)
import AppKit

extension NSApplication {

    @objc dynamic func newSendEvent(_ event: NSEvent) {
        newSendEvent(event)
        InactivityWatcher.shared.sendEvent()
    }

}
#endif
