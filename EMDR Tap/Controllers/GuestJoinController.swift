//
//  GuestJoinController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/11/22.
//

import UIKit

class GuestJoinController: UIViewController {

    // MARK: - Properties
    
    private var homeButton: CustomButton!
    private var hostIDField: UITextField!
    private var loginView: LoginView!
    

    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "bgMenuColor")

        homeButton = CustomButton(image: UIImage(systemName: "house.circle.fill"), asTemplate: true, shouldAnimatePress: true)
        homeButton.imageView?.tintColor = .white
        homeButton.delegate = self

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
        
        
        loginView = LoginView()
        loginView.delegate = self
        loginView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        let buttonPadding: CGFloat = 20
        let buttonSize: CGFloat = 30
        
        view.addSubview(homeButton)
//        view.addSubview(hostIDField)
        view.addSubview(loginView)

        NSLayoutConstraint.activate([
            homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: buttonPadding),
            homeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            homeButton.heightAnchor.constraint(equalToConstant: buttonSize),

//            hostIDField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            hostIDField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            hostIDField.widthAnchor.constraint(equalToConstant: 200),
//            hostIDField.heightAnchor.constraint(equalToConstant: 40),
            
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonPadding),
            loginView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: 100),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: loginView.bottomAnchor, constant: buttonPadding)
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
        
        DataService.docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                let vc = EMDRViewController()
                self.present(vc, animated: true)
            }
            else {
                print("no go, bro!")
            }
        }
        
        return true
    }
}


// MARK: - CustomButtonDelegate

extension GuestJoinController: CustomButtonDelegate {
    func didTapButton(_ button: CustomButton) {
        dismiss(animated: true)
    }
}


// MARK: - LoginViewDelegate

extension GuestJoinController: LoginViewDelegate {
    func didTapReturn(_ sessionID: Int) {
        DataService.setSessionID(sessionID)
        
        DataService.docRef.getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard snapshot.exists else {
                self.loginView.updateStatus("Invalid Session ID")
                return
            }

            let vc = EMDRViewController()
            self.present(vc, animated: true)
        }
    }
    
}
