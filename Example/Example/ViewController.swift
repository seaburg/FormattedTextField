//
//  ViewController.swift
//  Example
//
//  Created by Evgeniy Yurtaev on 26/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FormattedTextFieldDelegate {

    @IBOutlet private var textField: FormattedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.textAlignment = .center
        textField.placeholderMode = .always
        updateTextFieldMask()
    }

// MARK: - Actions

    @IBAction private func textFieldTextChanged(_ textField: FormattedTextField) {
        updateTextFieldMask()
    }

// MARK: - FormattedTextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeUnformattedText text: String, in range: NSRange, replacementString: String) -> Bool {
        return (replacementString.isEmpty || Int(replacementString) != nil)
    }

// MARK: - Private

    private func updateTextFieldMask() {
        let textMask = mask(forPhoneNumber: textField.unformattedText ?? "") ?? "+_ ___ ___ ________"
        let formatter = textField.textFormatter as? MaskTextFormatter
        if formatter?.mask != textMask {
            textField.textFormatter = MaskTextFormatter(mask: textMask, maskSymbol: "_")
        }

        let placeholderStartIndex = textMask.index(textMask.startIndex, offsetBy: (textField.text?.count ?? 0))
        textField.placeholder = String(textMask[placeholderStartIndex...])
    }

    private func mask(forPhoneNumber phoneNumber: String) -> String? {
        let masks: [(format: String, mask: String)] = [
            ("1", "+_ (___) ___ ____"),
            ("7", "+_ (___) ___ ____"),
            ("44", "+__ (___) ____ ____"),
            ("49", "+__ (_____) ___-____"),
            ("54", "+__ (___) ___ ____"),
            ("86", "+__ (___) ___ ____"),
            ("358", "+___ _ ___ ___"),
        ]
        return masks.first { (mask, _) -> Bool in
            phoneNumber.hasPrefix(mask)
        }?.mask
    }
}

