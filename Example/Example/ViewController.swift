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
        textField.textFormatter = MaskTextFormatter(mask: "+× ××× ××× ××××××××")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Actions

    @IBAction private func textFieldTextChanged(_ textField: FormattedTextField) {
        let textMask = mask(forPhoneNumber: textField.unformattedText ?? "") ?? "+× ××× ××× ××××××××"
        let formatter = textField.textFormatter! as! MaskTextFormatter
        if formatter.mask != textMask {
            textField.textFormatter = MaskTextFormatter(mask: textMask)
        }
    }

// MARK: - FormattedTextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeUnformattedText text: String, in range: NSRange, replacementString: String) -> Bool {
        return (replacementString.isEmpty || Int(replacementString) != nil)
    }

// MARK: - Actions
    private func mask(forPhoneNumber phoneNumber: String) -> String? {
        let masks: [(format: String, mask: String)] = [
            ("1", "+× (×××) ××× ××××"),
            ("7", "+× (×××) ××× ××××"),
            ("44", "+×× (×××) ×××× ××××"),
            ("49", "+×× (×××××) ×××-××××"),
            ("54", "+×× (×××) ××× ××××"),
            ("86", "+×× (×××) ××× ××××"),
            ("358", "+××× × ××× ×××"),
        ]
        return masks.first { (mask, _) -> Bool in
            phoneNumber.hasPrefix(mask)
        }?.mask
    }
}

