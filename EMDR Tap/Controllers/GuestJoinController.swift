//
//  GuestJoinController.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/11/22.
//

import UIKit
import FirebaseFirestore

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
        
        // FIXME: - Obviously read from input
        DataService.setSessionID(sessionID)
        
        print("Returning...")
        
        DataService.listener = DataService.docRef.addSnapshotListener({ (snapshot, error) in
            guard error == nil else { return print("Error getting docs: \(error!)") }
            guard let snapshot = snapshot, let data = snapshot.data() else { return }
            
            guard let isPlaying = data["isPlaying"] as? Bool,
                  let currentImage = data["currentImage"] as? Int,
                  let speed = data["speed"] as? Double,
                  let duration = data["duration"] as? TimeInterval else { return }
            
            print("Good")
            
            DataService.guestModel = FIRModel(id: DataService.docRef.documentID, speed: Float(speed), duration: duration, isPlaying: isPlaying, currentImage: currentImage)
            
            print("Data: \(data)")
        })
        
        print("Now go here")
        
        let vc = EMDRViewController()
        present(vc, animated: true)
        
        return true

    }
}
