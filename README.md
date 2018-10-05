# FormattedTextField
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FormattedTextField.svg)](https://img.shields.io/cocoapods/v/FormattedTextField.svg)

UITextField subclass that supports text formatting

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
        textField.textFormatter = MaskTextFormatter(mask: "8 (×××) ××× ××××")
        textField.placeholder = "___) ___ ____"
        textField.unformattedText = "1111111111"
    ...
Example
-----
![Example.gif](https://raw.githubusercontent.com/seaburg/FormattedTextField/master/Example/Example.gif)
