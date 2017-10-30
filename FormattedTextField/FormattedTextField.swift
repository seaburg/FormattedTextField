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
            if let formatter = textFormatter {
                text = formatter.formattedText(from: unformattedText)
            } else {
                text = unformattedText
            }
        }

        placeholderLabel.font = font
        placeholderLabel.textColor = UIColor(white: 170/255.0, alpha: 0.5)
        if let attributedPlaceholder = super.attributedPlaceholder {
            placeholderLabel.attributedText = attributedPlaceholder
        } else if let placeholder = super.placeholder {
            placeholderLabel.text = placeholder
        }
        // iOS 11: placeholderRect(forBounds:) returns empty rect when placeholder is empty
        super.placeholder = " "

        addSubview(placeholderLabel)
    }

    open var textFormatter: TextFromatter? {
        didSet(oldFormatter) {
            let text = (self.text ?? "")
            let selectedRange = selectedCharactersRange ?? text.startIndex..<text.startIndex

            var unformattedText = text
            var unformattedRange = selectedRange
            if let oldFormatter = oldFormatter {
                (unformattedText, unformattedRange) = oldFormatter.unformattedText(from: text, range: selectedRange)
            }

            var formattedText = unformattedText
            var formattedRange = unformattedRange
            if let formatter = textFormatter {
                (formattedText, formattedRange) = formatter.formattedText(from: unformattedText, range: unformattedRange)
            }

            self.text = formattedText
            if selectedTextRange != nil {
                selectedCharactersRange = formattedRange.upperBound..<formattedRange.upperBound
            }
        }
    }

    @IBInspectable open var unformattedText: String? {
        get {
            guard let text = text else {
                return nil
            }
            guard let formatter = textFormatter else {
                return text
            }
            let unformattedText = formatter.unformattedText(from: text)

            return unformattedText
        }
        set(value) {
            var formattedText = (value ?? "")
            if let formatter = textFormatter {
                formattedText = formatter.formattedText(from: formattedText)
            }

            if formattedText.characters.count > 0 || value != nil {
                text = formattedText
            } else {
                text = nil
            }
            placeholderLabel.isHidden = (formattedText.characters.count > 0)
        }
    }

    open override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set(value) {
            assertionFailure("masked text field unsupports attributed text")
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
        if let text = self.text {
            var attributes: [String: Any]? = nil
            if let placeholderFont = font {
                attributes = [NSFontAttributeName: placeholderFont]
            }
            let prefixWidth = (text as NSString).size(attributes: attributes).width
            placeholderFrame.origin.x += prefixWidth
            placeholderFrame.size.width -= prefixWidth
        }
        self.placeholderLabel.frame = placeholderFrame;
    }

    // MARK: - Private

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
        let text = self.text ?? ""
        let charactersRange = text.range(fromUtf16NsRange: range)!

        let unformattedText: String
        var unformattedRange: Range<String.Index>
        if let formatter = textFormatter {
            (unformattedText, unformattedRange) = formatter.unformattedText(from: text, range: charactersRange)
        } else {
            unformattedText = text
            unformattedRange = charactersRange
        }

        let isBackspace = (string.characters.count == 0 && unformattedRange.isEmpty)
        if isBackspace && unformattedRange.lowerBound != unformattedText.startIndex {
            unformattedRange = unformattedText.index(before: unformattedRange.lowerBound)..<unformattedRange.upperBound
        }

        if let originDelegate = (delegateProxy.delegate as? FormattedTextFieldDelegate),
            originDelegate.responds(to: #selector(FormattedTextFieldDelegate.textField(_:shouldChangeUnformattedText:in:replacementString:))) {
            let utf16UnformattedRange = unformattedText.utf16Nsrange(fromRange: unformattedRange)
            if !originDelegate.textField!(self, shouldChangeUnformattedText:unformattedText, in:utf16UnformattedRange, replacementString: string) {
                return false
            }
        }

        let newUnformattedText = unformattedText.replacingCharacters(in: unformattedRange, with: string)
        let selectionOffset = unformattedText.distance(from: unformattedText.startIndex, to: unformattedRange.lowerBound)
        let cursorPosition = newUnformattedText.index(newUnformattedText.startIndex, offsetBy: selectionOffset + string.characters.count)

        let formattedText: String
        let formattedRange: Range<String.Index>
        if let formatter = textFormatter {
            (formattedText, formattedRange) = formatter.formattedText(from: newUnformattedText, range: cursorPosition..<cursorPosition)
        } else {
            formattedText = newUnformattedText
            formattedRange = cursorPosition..<cursorPosition
        }
        self.text = formattedText
        selectedCharactersRange = formattedRange.upperBound..<formattedRange.upperBound

        placeholderLabel.isHidden = (newUnformattedText.characters.count > 0)

        sendActions(for: .editingChanged)

        return false
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
