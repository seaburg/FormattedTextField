//
//  StringExtensions.swift
//  MaskedTextField
//
//  Created by Evgeniy Yurtaev on 16/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import Foundation

extension String {
    func range(fromNsRange nsrange: NSRange) -> Range<String.Index>? {
        guard let lowerBound = index(startIndex, offsetBy: nsrange.location, limitedBy: endIndex) else {
            return nil
        }
        guard let upperBound = index(lowerBound, offsetBy: nsrange.length, limitedBy: endIndex) else {
            return nil
        }

        return lowerBound..<upperBound
    }

    func nsrange(fromRange range: Range<String.Index>) -> NSRange {
        let location = distance(from: startIndex, to: range.lowerBound)
        let length = distance(from: range.lowerBound, to: range.upperBound)

        return NSMakeRange(location, length)
    }

    func range(fromUtf16NsRange nsrange: NSRange) -> Range<String.Index>? {
        guard let utf16LowerBound = utf16.index(utf16.startIndex, offsetBy: nsrange.location, limitedBy: utf16.endIndex) else {
            return nil
        }
        guard let utf16UpperBound = utf16.index(utf16LowerBound, offsetBy: nsrange.length, limitedBy: utf16.endIndex) else {
            return nil
        }

        guard let lowerBound = String.Index(utf16LowerBound, within: self) else {
            return range(fromUtf16NsRange: NSMakeRange(nsrange.location + 1, nsrange.length))
        }
        guard let upperBound = String.Index(utf16UpperBound, within: self) else {
            return range(fromUtf16NsRange: NSMakeRange(nsrange.location, nsrange.length + 1))
        }

        return lowerBound..<upperBound
    }

    func utf16Nsrange(fromRange range: Range<String.Index>) -> NSRange? {
        guard let utf16LowerBound = range.lowerBound.samePosition(in: utf16) else {
            return nil;
        }
        guard let utf16UpperBound = range.upperBound.samePosition(in: utf16) else {
            return nil;
        }
        let location = utf16.distance(from: utf16.startIndex, to: utf16LowerBound)
        let length = utf16.distance(from: utf16LowerBound, to: utf16UpperBound)

        return NSMakeRange(location, length)
    }
}
