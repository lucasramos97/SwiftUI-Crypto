//
//  HapticManager.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 08/10/22.
//

import Foundation
import SwiftUI

struct HapticManager {
    
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
