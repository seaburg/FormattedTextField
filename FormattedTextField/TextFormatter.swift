//
//  TextFormatter.swift
//  FormattedTextField
//
//  Created by Evgeniy Yurtaev on 12/11/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import Foundation

public protocol TextFromatter {
    func formattedText(from text: String, range: Range<String.Index>) -> (text: String, range: Range<String.Index>)
    func unformattedText(from text: String, range: Range<String.Index>) -> (text: String, range: Range<String.Index>)
}

public extension TextFromatter {
    public func formattedText(from text: String) -> String {
        return formattedText(from: text, range: text.startIndex..<text.startIndex).text
    }

    public func unformattedText(from text: String) -> String {
        return unformattedText(from: text, range: text.startIndex..<text.startIndex).text
    }
}
