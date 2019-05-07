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
    public typealias Delegate = FormattedTextFieldDelegate

    public enum PlaceholderMode {
        case whileEmpty
        case always
    }

    deinit {
        removeTarget(self, action: #selector(self.textViewEditingChanged(_:)), for: .editingChanged)
    }

    public override init(frame: CGRect) {
        placeholderLabel = UILabel()

        super.init(frame: frame)
        commonInitFormattedTextField()
    }

    public required init?(coder aDecoder: NSCoder) {
        placeholderLabel = UILabel()

        super.init(coder: aDecoder)
        commonInitFormattedTextField()
    }

    private func commonInitFormattedTextField() {
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
        addSubview(placeholderLabel)

        addTarget(self, action: #selector(self.textViewEditingChanged(_:)), for: .editingChanged)

        if #available(iOS 11, *) {
            if smartInsertDeleteType != .no {
                print("[FormattedTextField] warning: smartInsertDeleteType is unsupported");
            }
        }
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

            if !formattedText.isEmpty || value != nil {
                text = formattedText
            } else {
                text = nil
            }
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

    open var placeholderMode: PlaceholderMode = .whileEmpty {
        didSet {
            setNeedsLayout()
        }
    }

    open override var placeholder: String? {
        get {
            return placeholderLabel.text
        }
        set(value) {
            placeholderLabel.text = value
            setNeedsLayout()
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

    open override var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set {
            super.textAlignment = newValue
            setNeedsLayout()
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

        layoutPlaceholder()
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: textRectInset)
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: textRectInset)
    }

    // MARK: - Private

    private var textRectInset: UIEdgeInsets {
        return isPlaceholderVisible ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: placeholderLabelWidth) : .zero
    }

    @objc private func textViewEditingChanged(_ sender: AnyObject?) {
        layoutPlaceholder()
    }

    private func layoutPlaceholder() {
        placeholderLabel.frame = placeholderFrame
    }

    private var placeholderFrame: CGRect {
        if !isPlaceholderVisible {
            return .zero
        }

        let textRect = isEditing ? editingRect(forBounds: bounds) : self.textRect(forBounds: bounds)

        var placeholderLabelFrame = textRect
        placeholderLabelFrame.size.width = placeholderLabelWidth

        switch textAlignment {
        case .center:
            placeholderLabelFrame.origin.x = textRect.midX + enteredTextWidth * 0.5
        case .left, .justified:
            fallthrough
        case .natural where UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight:
            placeholderLabelFrame.origin.x += enteredTextWidth
        case .right:
            placeholderLabelFrame.origin.x = textRect.maxX
        default:
            // TODO: Add support for right-to-left direction
            placeholderLabelFrame = .zero
        }
        return placeholderLabelFrame
    }

    private var isPlaceholderVisible: Bool {
        if placeholder?.isEmpty ?? true {
            return false
        }

        // Hides placeholder before text field adds scrolling text
        var isVisible = (placeholderAndTextRect.width - enteredTextWidth - placeholderHiddingGap >= placeholderLabelWidth)
        if isVisible {
            switch placeholderMode {
            case .always:
                isVisible = true
            case .whileEmpty:
                isVisible = unformattedText?.isEmpty ?? true
            }
        }
        return isVisible
    }

    private var placeholderAndTextRect: CGRect {
        return isEditing ? super.editingRect(forBounds: bounds) : super.textRect(forBounds: bounds)
    }

    // UITextFields adds scrolling before entered text fills all available width
    private var placeholderHiddingGap: CGFloat = 10

    private var enteredTextWidth: CGFloat {
        guard let text = self.text else {
            return 0
        }
        var attributes: [NSAttributedString.Key: Any]? = nil
        if let placeholderFont = font {
            attributes = [ .font: placeholderFont]
        }
        return (text as NSString).size(withAttributes: attributes).width
    }

    private var placeholderLabelWidth: CGFloat {
        return placeholderLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat.infinity)).width
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
        let text = self.text ?? ""
        guard let charactersRange = text.range(fromUtf16NsRange: range) else {
            return false
        }

        let unformattedText: String
        var unformattedRange: Range<String.Index>
        if let formatter = textFormatter {
            (unformattedText, unformattedRange) = formatter.unformattedText(from: text, range: charactersRange)
        } else {
            unformattedText = text
            unformattedRange = charactersRange
        }

        let isBackspace = (string.isEmpty && unformattedRange.isEmpty)
        if isBackspace && unformattedRange.lowerBound != unformattedText.startIndex {
            unformattedRange = unformattedText.index(before: unformattedRange.lowerBound)..<unformattedRange.upperBound
        }

        if let originDelegate = (delegateProxy.delegate as? Delegate),
            originDelegate.responds(to: #selector(FormattedTextFieldDelegate.textField(_:shouldChangeUnformattedText:in:replacementString:))) {
            guard let utf16UnformattedRange = unformattedText.utf16Nsrange(fromRange: unformattedRange) else {
                return false
            }
            if !originDelegate.textField!(self, shouldChangeUnformattedText:unformattedText, in:utf16UnformattedRange, replacementString: string) {
                return false
            }
        }

        let newUnformattedText = unformattedText.replacingCharacters(in: unformattedRange, with: string)
        let selectionOffset = unformattedText.distance(from: unformattedText.startIndex, to: unformattedRange.lowerBound)
        let cursorPosition = newUnformattedText.index(newUnformattedText.startIndex, offsetBy: selectionOffset + string.count)

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
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
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
