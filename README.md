# FormattedTextField
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FormattedTextField.svg)](https://img.shields.io/cocoapods/v/FormattedTextField.svg)

iOS formatted text field which supports symbols with variable-width encoding

Installation
------------
Carthage
```
github "seaburg/FormattedTextField"
```
CocoaPods
```
pod 'FormattedTextField'
```
Usage
-----
    import FormattedTextField
    ...
        let textField = FormattedTextField()
        textField.textMask = "8 (×××) ××× ××××"
        textField.placeholder = "___) ___ ____"
        textField.unformattedText = "1111111111"
    ...
