//
//  String.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 11/10/22.
//

import Foundation

extension String {
    
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
