//
//  DigitLabel.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/13/22.
//

import UIKit

class DigitLabel: UILabel {
    // MARK: - Properties
    
    var textValue: String!
    
    
    // MARK: - Initialization
    
    init(_ textValue: String = "") {
        super.init(frame: .zero)
        
        self.textValue = textValue
        
        font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        text = textValue
        textAlignment = .center
        textColor = .black
        backgroundColor = .white
        layer.borderColor = (UIColor(named: "bgMenuColor") ?? UIColor.black).withAlphaComponent(0.8).cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Helper Functions
    
    func setTextValue(_ value: String, withAnimation: Bool = false) {
        textValue = value
        text = textValue
        
        
        guard withAnimation else { return }
        
        transform = CGAffineTransform(rotationAngle: .pi / 24)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(rotationAngle: 0)
        }, completion: nil)
    }
    
    func setActive() {
        let speed: TimeInterval = 1.5
        UIView.animate(withDuration: speed, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.layer.borderColor = UIColor.systemBlue.cgColor
        }, completion: { _ in
            UIView.animate(withDuration: speed, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.layer.borderColor = UIColor.lightGray.cgColor
            }, completion: nil)
        })
    }
    
    func setInactive() {
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
