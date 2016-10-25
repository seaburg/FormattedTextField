//
//  FormattedTextField.swift
//  FormattedTextField
//
//  Created by Evgeniy Yurtaev on 16/10/2016.
//
//

import UIKit

@objc public protocol FormattedTextFieldDelegate: UITextFieldDelegate {
    @objc optional func textField(_ textField: UITextField, shouldChangeUnformattedText text: String, in range: NSRange, replacementString: String) -> Bool
}

open class FormattedTextField: UITextField {
    open static let maskSymbol: Character = "×"

    public override init(frame: CGRect) {
        placeholderLabel = UILabel()

        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        placeholderLabel = UILabel()

        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        delegateProxy.delegate = super.delegate
        super.delegate = delegateProxy

        if let unformattedText = unformattedText {
            var cursorPosition = 0
            text = formattedText(fromText: unformattedText, textMask: text, cursorPosition: &cursorPosition)
        }

        placeholderLabel.font = font
        placeholderLabel.textColor = UIColor(white: 170/255.0, alpha: 0.5)
        if let attributedPlaceholder = super.attributedPlaceholder {
            placeholderLabel.attributedText = attributedPlaceholder
        } else if let placeholder = super.placeholder {
            placeholderLabel.text = placeholder
        }
        addSubview(placeholderLabel)
    }

    @IBInspectable open var textMask: String? {
        didSet(oldMask) {
            var cursorPosition: Int = 0
            if let selectedRange = selectedCharachtersRange, let text = text {
                cursorPosition = text.distance(from: text.startIndex, to: selectedRange.lowerBound)
            } else {
                cursorPosition = 0
            }

            let unformattedText = unformatterText(fromText: (text ?? ""), textMask: oldMask, cursorPosition: &cursorPosition)
            let newFormattedText = formattedText(fromText: unformattedText, textMask: textMask, cursorPosition: &cursorPosition)
            text = newFormattedText

            if selectedTextRange != nil {
                let cursorIndex = newFormattedText.index(newFormattedText.startIndex, offsetBy: cursorPosition, limitedBy: newFormattedText.endIndex) ?? newFormattedText.endIndex
                selectedCharachtersRange = cursorIndex..<cursorIndex
            }
        }
    }

    @IBInspectable open var unformattedText: String? {
        get {
            guard let text = text else {
                return nil
            }
            var cursorPosition = 0
            let unformattedText = self.unformatterText(fromText: text, textMask: textMask, cursorPosition: &cursorPosition)

            return unformattedText
        }
        set(value) {
            var cursorPosition = 0
            let unformattedText = value ?? ""
            let formattedText = self.formattedText(fromText: unformattedText, textMask: textMask, cursorPosition: &cursorPosition)
            if formattedText.characters.count > 0 || value != nil {
                text = formattedText
            } else {
                text = nil
            }
            placeholderLabel.isHidden = (unformattedText.characters.count > 0)
        }
    }

    open override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set(value) {
            assert(false, "masked text field unsupports attributed text")
        }
    }

    open override var placeholder: String? {
        get {
            return placeholderLabel.text
        }
        set(value) {
            placeholderLabel.text = value
        }
    }

    open override var attributedPlaceholder: NSAttributedString? {
        get {
            return placeholderLabel.attributedText
        }
        set(value) {
            placeholderLabel.attributedText = value
        }
    }

    open override var font: UIFont? {
        get {
            return super.font
        }
        set(value) {
            super.font = value
            placeholderLabel.font = super.font
        }
    }

    open override var delegate: UITextFieldDelegate? {
        get {
            return delegateProxy
        }
        set(value) {
            delegateProxy.delegate = value
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        var placeholderFrame = self.placeholderRect(forBounds:bounds)
        if let mask = textMask, let firstMaskSymbolRange = mask.range(of: String(maskSymbol))  {
            let prefix = mask[mask.startIndex..<firstMaskSymbolRange.lowerBound]
            var attributes: [String: Any]? = nil
            if let placeholderFont = font {
                attributes = [NSFontAttributeName: placeholderFont]
            }
            let prefixWidth = (prefix as NSString).size(attributes: attributes).width
            placeholderFrame.origin.x += prefixWidth
            placeholderFrame.size.width -= prefixWidth
        }
        self.placeholderLabel.frame = placeholderFrame;
    }

    // MARK: - Private

    private var maskSymbol: Character {
        return type(of: self).maskSymbol
    }
    private let placeholderLabel: UILabel

    private lazy var delegateProxy: TextFieldDelegateProxy = {
        let shouldChangeFunc: (NSRange, String) -> Bool = { [unowned self] (range, string) in
            return self.shouldChangeCharacters(in: range, replacementString: string)
        }
        return TextFieldDelegateProxy(shouldChangeFunc: shouldChangeFunc)
    }()

    private func shouldChangeCharacters(in range: NSRange, replacementString string: String) -> Bool {
        if let shouldChange = delegateProxy.delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) {
            if !shouldChange {
                return false
            }
        }

        let formattedText = text ?? ""
        var charachtersRange = formattedText.nsrange(fromRange: formattedText.range(fromUtf16NsRange: range)!)

        var cursorPosition: Int
        if string.characters.count > 0 {
            cursorPosition = NSMaxRange(charachtersRange)
        } else {
            charachtersRange = deleteBackwardRange(fromRange: charachtersRange)
            cursorPosition = charachtersRange.location
        }

        var unformattedText = unformatterText(fromText: formattedText, textMask: textMask, cursorPosition: &cursorPosition)
        let unformattedRange = self.range(fromFormattedRange: charachtersRange)

        if let originDelegate = (delegateProxy.delegate as? FormattedTextFieldDelegate),
            originDelegate.responds(to: #selector(FormattedTextFieldDelegate.textField(_:shouldChangeUnformattedText:in:replacementString:))) {

            let utf16UnformattedRange = unformattedText.utf16Nsrange(fromRange: unformattedText.range(fromNsRange: unformattedRange)!)
            if !originDelegate.textField!(self, shouldChangeUnformattedText:unformattedText, in:utf16UnformattedRange, replacementString: string) {
                return false
            }
        }

        unformattedText.replaceSubrange(unformattedText.range(fromNsRange: unformattedRange)!, with: string)
        cursorPosition += string.characters.count

        let newFormattedText = self.formattedText(fromText: unformattedText, textMask: textMask, cursorPosition: &cursorPosition)
        text = newFormattedText
        placeholderLabel.isHidden = (unformattedText.characters.count > 0)

        cursorPosition = min(cursorPosition, newFormattedText.characters.count)
        let cursorIndex = newFormattedText.index(newFormattedText.startIndex, offsetBy: cursorPosition)
        selectedCharachtersRange = cursorIndex..<cursorIndex

        sendActions(for: .editingChanged)

        return false
    }

    private func unformatterText(fromText text: String, textMask: String?, cursorPosition: inout Int) -> String {
        guard let mask = textMask else {
            return text
        }
        let originCursorPosition = cursorPosition

        var unformattedText = String()
        for i in 0..<(min(mask.characters.count, text.characters.count)) {
            let maskCharacter = mask.characters[mask.index(mask.startIndex, offsetBy: i)]
            if maskCharacter == maskSymbol {
                let textCharacter = text.characters[text.index(text.startIndex, offsetBy: i)]
                unformattedText.append(textCharacter)
            } else if i < originCursorPosition {
                cursorPosition -= 1
            }
        }

        return unformattedText
    }

    private func formattedText(fromText text: String, textMask: String?, cursorPosition: inout Int) -> String {
        guard let mask = textMask else {
            return text
        }
        let originCursorPosition = cursorPosition

        var formattedText = String()
        var textIndex = 0
        for maskCharacter in mask.characters {
            if maskCharacter == maskSymbol {
                if textIndex >= text.characters.count {
                    break
                }
                let textCharacter = text.characters[text.index(text.startIndex, offsetBy: textIndex)]
                formattedText.append(textCharacter)
                textIndex += 1
            } else {
                formattedText.append(maskCharacter)
                if textIndex <= originCursorPosition {
                    cursorPosition += 1
                }
            }
        }

        return formattedText
    }

    private func range(fromFormattedRange range: NSRange) -> NSRange {
        guard let mask = textMask else {
            return range
        }

        let maskCharachtersRange = mask.range(fromNsRange: range)!
        var location = 0
        for character in mask[mask.startIndex..<maskCharachtersRange.lowerBound].characters {
            if character == maskSymbol {
                location += 1
            }
        }
        var length = 0
        for character in mask[maskCharachtersRange].characters {
            if character == maskSymbol {
                length += 1
            }
        }
        return NSMakeRange(location, length)
    }

    private func deleteBackwardRange(fromRange range: NSRange) -> NSRange {
        guard let mask = self.textMask else {
            return range
        }
        let charachtersRange = mask.range(fromNsRange: range)!
        if mask[charachtersRange].contains(String(maskSymbol)) {
            return range
        }

        let searchRange = mask.startIndex..<charachtersRange.lowerBound

        let deleteRange: Range<String.Index>
        if let removedSymbolRange = mask.range(of: String(maskSymbol), options: .backwards, range: searchRange, locale: nil) {
            deleteRange = removedSymbolRange.lowerBound..<charachtersRange.upperBound
        } else {
            deleteRange = charachtersRange.upperBound..<charachtersRange.upperBound
        }

        return mask.nsrange(fromRange: deleteRange)
    }
}

// MARK: - TextFieldDelegateProxy

private class TextFieldDelegateProxy: NSObject, UITextFieldDelegate {
    weak var delegate: UITextFieldDelegate?
    private var shouldChangeFunc: (NSRange, String) -> Bool

    init(shouldChangeFunc: @escaping (NSRange, String) -> Bool) {
        self.shouldChangeFunc = shouldChangeFunc
        super.init()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }

    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return shouldChangeFunc(range, string)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear?(textField) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
}
