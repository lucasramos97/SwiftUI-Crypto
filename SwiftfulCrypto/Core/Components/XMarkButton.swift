//
//  XMarkButton.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 08/10/22.
//

import SwiftUI

struct XMarkButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
        }
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton { }
    }
}
