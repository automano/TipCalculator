//
//  ViewController.swift
//  TipCalculator
//
//  Created by Zhening Li on 3/16/18.
//  Copyright © 2018 Zhening Li. All rights reserved.
//  SuperEasyApp

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    // OUtlets
    @IBOutlet weak var tenPercentTipLabel: UILabel!
    @IBOutlet weak var fifteenPercentTipLabel: UILabel!
    @IBOutlet weak var eighteenPercentTipLabel: UILabel!
    
    @IBOutlet weak var tenPercentTotalLabel: UILabel!
    @IBOutlet weak var fifteenPercentTotalLabel: UILabel!
    @IBOutlet weak var eignteenPercentTotalLabel: UILabel!
    
    @IBOutlet weak var errorInfo: UILabel!
    
    @IBOutlet weak var billTextField: UITextField!
    
    var billAmount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        billTextField.delegate = self
        billTextField.placeholder = updateAmount()
        
        errorInfo.text = ""
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    // Actions
    @IBAction func calculateTipButtonPressed(_ sender: Any) {
        print("Calculate tip")
        hideKeyboard()
        calculateALlTips()
    }
    
    // Methods or Functions
    func hideKeyboard() {
        billTextField.resignFirstResponder()
    }
    
    func calculateALlTips(){
        guard let subtotal = convertCurrencyToDouble(input: billTextField.text!) else {
            print("Not a number!:\(billTextField.text!)")
            showErrorInfo(error: "Error: Invalid format input")
            return
        }
        showErrorInfo(error: "")
        print("The subtotal is:\(subtotal)")
        
        // calculate tip
        let tip1 = calculateTip(subtotal: subtotal, tipPercent: 10.0)
        let tip2 = calculateTip(subtotal: subtotal, tipPercent: 15.0)
        let tip3 = calculateTip(subtotal: subtotal, tipPercent: 18.0)
        
        let total1 = calculateTotal(subtotal: subtotal, tipPercent: 10.0)
        let total2 = calculateTotal(subtotal: subtotal, tipPercent: 15.0)
        let total3 = calculateTotal(subtotal: subtotal, tipPercent: 18.0)
        
        // Update UI
        tenPercentTipLabel.text = convertDoubleToCurrency(amount: tip1)
        fifteenPercentTipLabel.text = convertDoubleToCurrency(amount: tip2)
        eighteenPercentTipLabel.text = convertDoubleToCurrency(amount: tip3)
        
        tenPercentTotalLabel.text = convertDoubleToCurrency(amount: total1)
        fifteenPercentTotalLabel.text = convertDoubleToCurrency(amount: total2)
        eignteenPercentTotalLabel.text = convertDoubleToCurrency(amount: total3)
    }
    
    func calculateTip(subtotal:Double,tipPercent:Double)->Double{
        return subtotal * (tipPercent / 100.0)
    }
    func calculateTotal(subtotal:Double,tipPercent:Double)->Double{
        return subtotal * (tipPercent / 100.0) + subtotal
    }
    
    func convertCurrencyToDouble(input: String)->Double?{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        return numberFormatter.number(from: input)?.doubleValue
    }
    
    func convertDoubleToCurrency(amount:Double)->String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        
        return numberFormatter.string(from: NSNumber(value:amount))!
    }
    
    @objc func keyBoardWillChange(notification: Notification){
        print("Keyboard will show: \(notification.name.rawValue)")
        
        guard let keyboardReact = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)? .cgRectValue else {
            return
        }
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardReact.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    func showErrorInfo(error: String){
        errorInfo.text = error
    }
    
    // UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        calculateALlTips()
        return true
    }
    
    // currency formatter from https://apoorv.blog/currency-format-input-uitextfield-swift/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)->Bool{
        if let digit = Int(string){
            billAmount = billAmount * 10 + digit
            
            // input too large
            if(billAmount > 1_000_000_000_00){
                showErrorInfo(error: "Are you kidding? 1 billion for food?")
                billTextField.text = " "
                billAmount = 0
            }else{
                showErrorInfo(error: "")
                billTextField.text = updateAmount()
            }
        }
        if string == "" {
            billAmount = billAmount / 10
            billTextField.text = updateAmount()
        }
        return false
    }
    
    func updateAmount()->String?{
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(billAmount/100) + Double(billAmount%100)/100
        return formatter.string(from: NSNumber(value:amount))
    }

}

