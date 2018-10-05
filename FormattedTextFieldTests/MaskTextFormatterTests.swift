//
//  FormattedTextFieldTests.swift
//  FormattedTextFieldTests
//
//  Created by Evgeniy Yurtaev on 12/11/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import XCTest
@testable import FormattedTextField

class FormattedTextFieldTests: XCTestCase {

    func testSimpleStringFormatting() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123456"
        let unformattedRange = string.startIndex..<string.endIndex
        let result = textFormatter.formattedText(from: string, range: unformattedRange)

        XCTAssertEqual(result.text, "123 456")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 7)
    }

    func testFormattingWithRangeAtEnd() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123456"
        let unformattedRange = string.endIndex..<string.endIndex

        let result = textFormatter.formattedText(from: string, range: unformattedRange)
        let resultRange = result.text.nsrange(fromRange: result.range)

        XCTAssertEqual(resultRange.location, 7)
        XCTAssertEqual(resultRange.length, 0)
    }

    func testFormattingWithFirstHalfTextRange() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123456"
        let unformattedRange = string.startIndex..<string.index(string.startIndex, offsetBy: 3)

        let result = textFormatter.formattedText(from: string, range: unformattedRange)
        let resultRange = result.text.nsrange(fromRange: result.range)

        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 4)
    }

    func testFormattingWithSecondHalfTextRange() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123456"
        let unformattedRange = string.index(string.startIndex, offsetBy: 3)..<string.endIndex

        let result = textFormatter.formattedText(from: string, range: unformattedRange)
        let resultRange = result.text.nsrange(fromRange: result.range)

        XCTAssertEqual(resultRange.location, 3)
        XCTAssertEqual(resultRange.length, 4)
    }

    func testFormattingTextWithPrefix() {
        let textFormatter = MaskTextFormatter(mask: "+7 (×××) ××× ×× ××")
        let string = "9170741111"

        let result = textFormatter.formattedText(from: string, range: string.startIndex..<string.endIndex)
        XCTAssertEqual(result.text, "+7 (917) 074 11 11")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 4)
        XCTAssertEqual(resultRange.length, 14)
    }

    func testFormattingTextWithVariableWidthEncodedSymbols() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "🐶🦄🐱🐣🐧"
        let range = string.index(string.startIndex, offsetBy: 1)..<string.index(string.startIndex, offsetBy: 4)

        let result = textFormatter.formattedText(from: string, range: range)
        XCTAssertEqual(result.text, "🐶🦄🐱 🐣🐧")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 1)
        XCTAssertEqual(resultRange.length, 4)
    }

    func testFormattingTextWithVariableWidthEncodedSymbolsMask() {
        let textFormatter = MaskTextFormatter(mask: "🐶×🦄×🐱×🐧×🐤×")
        let string = "12345"
        let range = string.index(string.startIndex, offsetBy: 0)..<string.index(string.startIndex, offsetBy: 3)

        let result = textFormatter.formattedText(from: string, range: range)
        XCTAssertEqual(result.text, "🐶1🦄2🐱3🐧4🐤5")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 1)
        XCTAssertEqual(resultRange.length, 6)
    }

    func testFormattingTextWithEmptyMask() {
        let textFormatter = MaskTextFormatter(mask: "empty")
        let string = "12345"

        let result = textFormatter.formattedText(from: string, range: string.startIndex..<string.endIndex)
        XCTAssertEqual(result.text, "empty")
        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 0)
    }

    func testFormattingTextWithOneSymbolAndPrefixMask() {
        let textFormatter = MaskTextFormatter(mask: "+× ××× ××× ×× ××")
        let string = "7"

        let range = string.index(string.startIndex, offsetBy: 1)..<string.endIndex
        let result = textFormatter.formattedText(from: string, range: range)

        XCTAssertEqual(result.text, "+7 ")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 2)
        XCTAssertEqual(resultRange.length, 1)
    }

    func testSampleStringUnformatting() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123 456"
        let formattedRange = string.startIndex..<string.endIndex
        let result = textFormatter.unformattedText(from: string, range: formattedRange)

        XCTAssertEqual(result.text, "123456")
        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 6)
    }

    func testUnformattingPartialText() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123 4"
        let formattedRange = string.startIndex..<string.endIndex
        let result = textFormatter.unformattedText(from: string, range: formattedRange)

        XCTAssertEqual(result.text, "1234")
        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 4)
    }

    func testUnformattingWithFirstHalfTextRange() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123 456"
        let formattedRange = string.startIndex..<string.index(string.startIndex, offsetBy: 3)

        let result = textFormatter.unformattedText(from: string, range: formattedRange)
        let resultRange = result.text.nsrange(fromRange: result.range)

        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 3)
    }

    func testUnformattingWithSecondHalfTextRange() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "123 456"
        let unformattedRange = string.index(string.startIndex, offsetBy: 3)..<string.endIndex

        let result = textFormatter.unformattedText(from: string, range: unformattedRange)
        let resultRange = result.text.nsrange(fromRange: result.range)

        XCTAssertEqual(resultRange.location, 3)
        XCTAssertEqual(resultRange.length, 3)
    }

    func testUnformattingTextWithPrefixAndFullTextRange() {
        let textFormatter = MaskTextFormatter(mask: "+7 (×××) ××× ×× ××")
        let string = "+7 (917) 074 11 11"

        let result = textFormatter.unformattedText(from: string, range: string.startIndex..<string.endIndex)

        XCTAssertEqual(result.text, "9170741111")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 10)
    }

    func testUnformattingTextWithPrefixAndFTailTextRange() {
        let textFormatter = MaskTextFormatter(mask: "+7 (×××) ××× ×× ××")
        let string = "+7 (917) 074 11 11"

        let range = string.index(string.startIndex, offsetBy: 4)..<string.endIndex
        let result = textFormatter.unformattedText(from: string, range: range)

        XCTAssertEqual(result.text, "9170741111")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 10)
    }

    func testUnformattingTextWithVariableWidthEncodedSymbols() {
        let textFormatter = MaskTextFormatter(mask: "××× ×××")
        let string = "🐶🦄🐱 🐣🐧"
        let range = string.index(string.startIndex, offsetBy: 1)..<string.index(string.startIndex, offsetBy: 5)

        let result = textFormatter.unformattedText(from: string, range: range)
        XCTAssertEqual(result.text, "🐶🦄🐱🐣🐧")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 1)
        XCTAssertEqual(resultRange.length, 3)
    }

    func testUnformattingTextWithVariableWidthEncodedSymbolsMask() {
        let textFormatter = MaskTextFormatter(mask: "🐶×🦄×🐱×🐧×🐤×")
        let string = "🐶1🦄2🐱3🐧4🐤5"
        let range = string.index(string.startIndex, offsetBy: 1)..<string.index(string.startIndex, offsetBy: 9)

        let result = textFormatter.unformattedText(from: string, range: range)
        XCTAssertEqual(result.text, "12345")

        let resultRange = result.text.nsrange(fromRange: result.range)
        XCTAssertEqual(resultRange.location, 0)
        XCTAssertEqual(resultRange.length, 4)
    }
}
