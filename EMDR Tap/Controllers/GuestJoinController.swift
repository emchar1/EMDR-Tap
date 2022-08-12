//
//  GuestJoinController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/11/22.
//

import UIKit

class GuestJoinController: UIViewController {

    // MARK: - Properties
    
    private var hostIDField: UITextField!
    

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "bgMenuColor")
        
        hostIDField = UITextField()
        hostIDField.backgroundColor = .white
        hostIDField.font = UIFont(name: "HelveticaNeue", size: 20)
        hostIDField.placeholder = "Enter Session ID"
        hostIDField.borderStyle = .roundedRect
        hostIDField.keyboardType = .numberPad
        hostIDField.addDoneCancelToolbar(onDone: (target: self, action: #selector(donePressed)),
                                         onCancel: (target: self, action: #selector(cancelPressed)))
        hostIDField.delegate = self
        hostIDField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        view.addSubview(hostIDField)
        
        NSLayoutConstraint.activate([
            hostIDField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostIDField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostIDField.widthAnchor.constraint(equalToConstant: 200),
            hostIDField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc private func donePressed() {
        print("Enter pressed")
        hostIDField.resignFirstResponder()

    }
    
    @objc private func cancelPressed() {
        hostIDField.resignFirstResponder()
    }
}



// MARK: - TextFieldDelegate

extension GuestJoinController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.text != nil else { return true }
        
        return textField.text!.count + string.count <= 4
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, text.count == 4, let sessionID = Int(text), DataService.sessionType == .guest else { return true }
        
        DataService.setSessionID(sessionID)
        
        let vc = EMDRViewController()
        present(vc, animated: true)
        
        return true
    }
}
