//
//  MaskTextFormatter.swift
//  FormattedTextField
//
//  Created by Evgeniy Yurtaev on 12/11/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import Foundation

public class MaskTextFormatter: TextFromatter {
    public let mask: String
    public let maskSymbol: Character

    public init(mask: String, maskSymbol: Character = "×") {
        self.mask = mask
        self.maskSymbol = maskSymbol
    }

    public func formattedText(from text: String, range: Range<String.Index>) -> (text: String, range: Range<String.Index>) {
        let unformattedRange = NSMakeRange(
            text.distance(from: text.startIndex, to: range.lowerBound),
            text.distance(from: range.lowerBound, to: range.upperBound)
        )

        guard let prefixEndIndex = mask.range(of: String(maskSymbol))?.lowerBound else {
            return (mask, mask.startIndex..<mask.startIndex)
        }
        var formattedText = mask[mask.startIndex..<prefixEndIndex]
        var formattedRange = NSMakeRange(formattedText.count, 0)

        var index = 0
        for maskCharacter in mask[prefixEndIndex..<mask.endIndex] {
            if index < unformattedRange.location {
                formattedRange.location += 1
            } else if index < NSMaxRange(unformattedRange) {
                formattedRange.length += 1
            }

            if maskCharacter == maskSymbol {
                if index >= text.count {
                    break
                }
                let textCharacter = text[text.index(text.startIndex, offsetBy: index)]
                formattedText.append(textCharacter)
                index += 1
            } else {
                if index == NSMaxRange(unformattedRange) {
                    formattedRange.length += 1
                }
                formattedText.append(maskCharacter)
            }
        }

        let lowerBound = formattedText.index(formattedText.startIndex, offsetBy: formattedRange.location)
        let upperBound = formattedText.index(lowerBound, offsetBy: formattedRange.length)

        return (String(formattedText), lowerBound..<upperBound)
    }

    public func unformattedText(from text: String, range: Range<String.Index>) -> (text: String, range: Range<String.Index>) {
        let formattedRange = NSMakeRange(
            text.distance(from: text.startIndex, to: range.lowerBound),
            text.distance(from: range.lowerBound, to: range.upperBound)
        )

        var unformattedText = String()
        var unformattedRange = NSMakeRange(0, 0)
        for i in 0..<(min(mask.count, text.count)) {
            let index = mask.index(mask.startIndex, offsetBy: i)
            let maskCharacter = mask[index]
            if maskCharacter != maskSymbol {
                continue;
            }

            let textCharacter = text[text.index(text.startIndex, offsetBy: i)]
            unformattedText.append(textCharacter)

            if i < formattedRange.location {
                unformattedRange.location += 1
            } else if i < NSMaxRange(formattedRange) {
                unformattedRange.length += 1
            }
        }

        let lowerBound = unformattedText.index(unformattedText.startIndex, offsetBy: unformattedRange.location)
        let upperBound = unformattedText.index(lowerBound, offsetBy: unformattedRange.length)

        return (unformattedText, lowerBound..<upperBound)
    }
}
