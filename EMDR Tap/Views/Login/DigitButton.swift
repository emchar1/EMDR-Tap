//
//  DigitButton.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/13/22.
//

import UIKit

protocol DigitButtonDelegate: AnyObject {
    func didTapButton(_ sender: DigitButton)
}

class DigitButton: UIButton {
    
    // MARK: - Properties
    
    let buttonSize: CGFloat = 40
    private let buttonDepth: CGFloat = 2
    var textValue: String!
    
    weak var delegate: DigitButtonDelegate?

    
    // MARK: - Initialization
    
    init(_ textValue: String) {
        super.init(frame: .zero)
        
        self.textValue = textValue
        
        setTitle(textValue, for: .normal)
        setTitleColor(UIColor(named: "bgMenuColor"), for: .normal)
        backgroundColor = .white
        alpha = 0.75
        
        layer.cornerRadius = buttonSize / 2
        layer.shadowOffset = CGSize(width: buttonDepth, height: buttonDepth)
        layer.shadowRadius = buttonDepth
        layer.shadowOpacity = 0.25
        clipsToBounds = true
        layer.masksToBounds = false
        
        addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonTouchDragExit(_:)), for: .touchDragExit)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    // MARK: - Helper Functions
    
    @objc private func buttonTouchDown(_ sender: DigitButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.transform = CGAffineTransform(translationX: self.buttonDepth, y: self.buttonDepth)
            self.layer.shadowOpacity = 0
        }, completion: nil)
    }
    
    @objc private func buttonTouchUpInside(_ sender: DigitButton) {
        animateTouchUp(completion: nil)

        delegate?.didTapButton(sender)
    }
    
    @objc private func buttonTouchDragExit(_ sender: DigitButton) {
        animateTouchUp(completion: nil)
    }
    
    private func animateTouchUp(completion: ((Bool) -> ())?) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
            self.layer.shadowOpacity = 0.25
        }, completion: completion)
    }
}
