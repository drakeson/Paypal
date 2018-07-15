//
//  ViewController.swift
//  Paypal
//
//  Created by Drakeson 007 on 15/07/2018.
//  Copyright © 2018 Code256.Ug. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PayPalPaymentDelegate {

    // For PayPal integration, we need to follow these steps
    // 1. Add Paypal config. in AppDelegate
    // 2. Create PayPal object
    // 3. Declare payment configurations
    // 4. Implement PayPalPaymentDelegate
    // 5. Add payment items and related details
    
    var payPalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Kato Drake Smith"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.sivaganesh.com/privacy.html")! as URL
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.sivaganesh.com/useragreement.html")! as URL
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0] 
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        PayPalMobile.preconnect(withEnvironment: environment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        })
    }

    @IBAction func payPressed(_ sender: Any) {
        let item1 = PayPalItem(name: "Kato Drake Smith", withQuantity: 1, withPrice: NSDecimalNumber(string: "9.99"), withCurrency: "USD", withSku: "drakeson")
        
        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Kato Drake Smith", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self as PayPalPaymentDelegate)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            
            print("Payment not processalbe: \(payment)")
        }
    }
}

