//
//  UserPrerencesViewController.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-27.
//

import UIKit
import CoreData
// UserPreferencesViewController manages the UI for setting and saving user preferences.
class UserPreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // MARK: - Outlets for the UI elements
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var unitSelectionButton: UIButton!
    @IBOutlet weak var themeSelectionButton: UIButton!
    @IBOutlet weak var locationTextField1: UITextField!
    @IBOutlet weak var locationTextField2: UITextField!
    @IBOutlet weak var locationTextField3: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // Picker views for selecting units and themes
    var unitsPickerView = UIPickerView()
    var themePickerView = UIPickerView()
    
    // Options for units and themes
    var unitOptions = ["Celsius", "Farenheit"]
    var themeOptions = ["Light", "Dark"]

    // Placeholder for user data that will be loaded
    var defaultUserData: [String: Any]?
    
    // CoreData properties
       var managedObjectContext: NSManagedObjectContext!
    
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
           super.viewDidLoad()
           setupPickers()
           // Initialize the managedObjectContext
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           managedObjectContext = appDelegate.persistentContainer.viewContext
           loadDefaultUserData()
       }
    // Sets up the picker views' delegates and data sources.
    func setupPickers() {
        unitsPickerView.delegate = self
        unitsPickerView.dataSource = self
        themePickerView.delegate = self
        themePickerView.dataSource = self
        // Set unique tags to differentiate the picker views
            unitsPickerView.tag = 1
            themePickerView.tag = 2
    }
    // Loads user data and updates the UI accordingly.
    func loadDefaultUserData() {
        // Simulated data loading process
        defaultUserData = ["unit": "Celsius", "theme": "Light", "locations": ["Sudbury", "Toronto", "Montreal"]]
        // Update the UI based on this data
            if let unit = defaultUserData?["unit"] as? String {
                unitSelectionButton.setTitle(unit, for: .normal)
            }
            
            if let theme = defaultUserData?["theme"] as? String {
                themeSelectionButton.setTitle(theme, for: .normal)
            }
            
            if let locations = defaultUserData?["locations"] as? [String], locations.count >= 3 {
                locationTextField1.text = locations[0]
                locationTextField2.text = locations[1]
                locationTextField3.text = locations[2]
            }
    }
    // MARK: - Actions for the unit and theme selection buttons
    // Presents a picker alert allowing the user to select a unit.
    @IBAction func unitSelectionButtonTapped(_ sender: UIButton) {
        let pickerAlert = UIAlertController(title: "Select Unit", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        pickerAlert.isModalInPresentation = true  // for iPad
        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        pickerView.tag = 1
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerAlert.view.addSubview(pickerView)

        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            // Get the selected row
            let row = pickerView.selectedRow(inComponent: 0)
            // Set the button title to the selected unit
            self.unitSelectionButton.setTitle(self.unitOptions[row], for: .normal)
        }
        pickerAlert.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pickerAlert.addAction(cancelAction)
        
        self.present(pickerAlert, animated: true)
    }
    // Presents a picker alert allowing the user to select a theme.
    @IBAction func themeSelectionButtonTapped(_ sender: UIButton) {
        let pickerAlert = UIAlertController(title: "Select Theme", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        pickerAlert.isModalInPresentation = true  // for iPad
        
        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        pickerView.tag = 2
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerAlert.view.addSubview(pickerView)

        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            // Get the selected row
            let row = pickerView.selectedRow(inComponent: 0)
            // Set the button title to the selected theme
            self.themeSelectionButton.setTitle(self.themeOptions[row], for: .normal)
        }
        pickerAlert.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pickerAlert.addAction(cancelAction)
        
        self.present(pickerAlert, animated: true)
    }
    // Saves the user preferences when the save button is tapped.
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
            // Validate inputs...
        
        guard let username = usernameTextField.text, !username.isEmpty else {
                presentAlert(title: "Input Error", message: "Username cannot be empty.")
                return
            }

            let locations = [locationTextField1.text, locationTextField2.text, locationTextField3.text].compactMap { $0 }.filter { !$0.isEmpty }
            if locations.isEmpty {
                presentAlert(title: "Input Error", message: "Please enter at least one location.")
                return
            }

            // Access the CoreData managedObjectContext from the AppDelegate
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext

            // Create a UserPreference managed object
            if let userPreference = NSEntityDescription.insertNewObject(forEntityName: "UserPreference", into: managedObjectContext) as? UserPreference {
                userPreference.username = usernameTextField.text
                userPreference.unit = unitSelectionButton.title(for: .normal)
                userPreference.theme = themeSelectionButton.title(for: .normal)
                userPreference.location1 = locationTextField1.text
                userPreference.location2 = locationTextField2.text
                userPreference.location3 = locationTextField3.text

                do {
                    // Save the changes to CoreData
                    try managedObjectContext.save()
                    presentAlert(title: "Success", message: "Preferences saved successfully.")
                } catch {
                    presentAlert(title: "Save Error", message: "There was a problem saving your preferences. Please try again.")
                }
            }
        }

    // MARK: - UIPickerViewDelegate & DataSource
    // Number of components for the picker view.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // Number of rows in each component of the picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 { // unitsPickerView
            return unitOptions.count
        } else { // themePickerView
            return themeOptions.count
        }
    }
    // Title for each row in the picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 { // unitsPickerView
            return unitOptions[row]
        } else { // themePickerView
            return themeOptions[row]
        }
    }
    // Handles the selection of a row in the picker view.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 { // unitsPickerView
            unitSelectionButton.setTitle(unitOptions[row], for: .normal)
        } else { // themePickerView
            themeSelectionButton.setTitle(themeOptions[row], for: .normal)
        }
    }

    // MARK: - UITextFieldDelegate
    // Allows the keyboard to be dismissed when the 'return' key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Method to be called when the "Load" button is tapped
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            presentAlert(title: "Username Required", message: "Please enter a username to load preferences.")
            return
        }
        loadDataForUser(username)
    }

    // Method to be called when the username text field editing ends
    @IBAction func usernameEditingDidEnd(_ sender: UITextField) {
        guard let username = sender.text, !username.isEmpty else {
            return
        }
        loadDataForUser(username)
    }

    // MARK: - Load Data and Alert Presentation methods
    // Loads data for a given username and updates the UI.
    private func loadDataForUser(_ username: String) {
        // Access the CoreData managedObjectContext from the AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext

        // Create a fetch request to fetch UserPreference objects based on the username
        let fetchRequest = NSFetchRequest<UserPreference>(entityName: "UserPreference")
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)

        do {
            let userPreferences = try managedObjectContext.fetch(fetchRequest)

            if let userPreference = userPreferences.first {
                // Update the UI with the fetched preferences
                if let unit = userPreference.unit {
                    unitSelectionButton.setTitle(unit, for: .normal)
                }
                if let theme = userPreference.theme {
                    themeSelectionButton.setTitle(theme, for: .normal)
                }
                if let location1 = userPreference.location1 {
                    locationTextField1.text = location1
                }
                if let location2 = userPreference.location2 {
                    locationTextField2.text = location2
                }
                if let location3 = userPreference.location3 {
                    locationTextField3.text = location3
                }
            } else {
                presentAlert(title: "Not Found", message: "No preferences found for the username '\(username)'.")
            }
        } catch {
            presentAlert(title: "Error", message: "Failed to fetch user preferences.")
        }
    }

    // Helper function to present an alert with a title and a message
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
