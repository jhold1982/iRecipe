//
//  ViewController.swift
//  iRecipe
//
//  Created by Justin Hold on 3/20/24.
//

import UIKit
import Security

class ViewController: UIViewController, UITextFieldDelegate {

	
	// MARK: - @IBOUTLETS
	@IBOutlet var nameField: UITextField!
	@IBOutlet var emailField: UITextField!
	@IBOutlet var passwordField: UITextField!
	
	// MARK: - VIEWDIDLOAD
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		title = "iRecipe"
		nameField.delegate = self
		emailField.delegate = self
	}
	
	// MARK: - @IBACTION
	@IBAction func signUpButton(_ sender: UIButton) {
		guard let name = nameField.text, !name.isEmpty,
			  let email = emailField.text, !email.isEmpty,
			  let password = passwordField.text, !password.isEmpty
				
		else {
			showAlert(message: "Please enter all fields.")
			return
		}
		
		saveToKeychain(name: name, email: email, password: password)
		
		// Clear fields after sign up
		nameField.text = ""
		emailField.text = ""
		passwordField.text = ""
	}
	

	// MARK: - FUNCTIONS
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		// Combine current text with replacement text
		let currentText = textField.text ?? ""
		let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
		
		// Check if the updatedText has at least 3 characters
		if updatedText.count >= 3 || !string.isEmpty {
			return true
		} else {
			showAlert(message: "Your name should be at least 3 characters long.")
			return false
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// Validate email format when editing ends
		if let email = textField.text, !isValidEmail(email) {
			showAlert(message: "Please enter a valid email.")
		}
	}
	
	func isValidEmail(_ email: String) -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
		return emailPredicate.evaluate(with: email)
	}
	
	
	
	func showAlert(message: String) {
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true)
	}
	
	func saveToKeychain(name: String, email: String, password: String) {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: "userCredentials",
			kSecValueData as String: password.data(using: .utf8)!,
			kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		]
		
		// Delete existing item from Keychain if it exists
		SecItemDelete(query as CFDictionary)
		
		// Add new item to Keychain
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {
			print("Error saving items to Keychain: \(status)")
			return
		}
		print("User credentials saved successfully!")
	}
}

