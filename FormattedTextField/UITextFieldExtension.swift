//
//  UITextFieldExtension.swift
//  FormattedTextField
//
//  Created by Evgeniy Yurtaev on 25/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import UIKit

extension UITextField {
    var selectedCharactersRange: Range<String.Index>? {
        get {
            guard let selectedTextRange = selectedTextRange else {
                return nil
            }
            guard let text = text else {
                return nil
            }
            let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
            let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
            let range = text.range(fromUtf16NsRange: NSMakeRange(location, length))

            return range
        }
        set(value) {
            guard let value = value else {
                selectedTextRange = nil
                return
            }
            guard let text = text else {
                return
            }
            guard let utf16Range = text.utf16Nsrange(fromRange: value) else {
                selectedTextRange = nil
                return
            }

            let from = position(from: beginningOfDocument, offset: utf16Range.location)!
            let to = position(from: from, offset: utf16Range.length)!
            selectedTextRange = textRange(from: from, to: to)
        }
    }
}
