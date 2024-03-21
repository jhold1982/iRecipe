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
	/// Method for validating name text field
	/// - Parameters:
	///   - textField: The name field
	///   - range: Range of number of characters we are validating
	///   - string: The text user has entered
	/// - Returns: True or False based on if user has entered a name that is at least 3 characters or longer.
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
	
	/// Method needed for registering input of textFields
	/// - Parameter textField: name, email, password fields
	/// - Returns: True or False on whether info was input to those fields
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	/// Method for validating email field has been entered
	/// - Parameter textField: the user input field
	func textFieldDidEndEditing(_ textField: UITextField) {
		// Validate email format when editing ends
		if let email = textField.text, !isValidEmail(email) {
			showAlert(message: "Please enter a valid email.")
		}
	}
	
	/// Checks email text field input for validation
	/// - Parameter email: user inputted email address
	/// - Returns: returns true or false based on whether user input meets validation criteria
	func isValidEmail(_ email: String) -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
		return emailPredicate.evaluate(with: email)
	}
	
	/// Method for displaying an alert
	/// - Parameter message: changes message when method is called based on alert context
	func showAlert(message: String) {
		let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true)
	}
	
	/// Method for saving user input to keychain
	/// - Parameters:
	///   - name: First and Last name of user
	///   - email: email address of user
	///   - password: password for user
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

