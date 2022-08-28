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
    var isDeleteButton = false
    
    weak var delegate: DigitButtonDelegate?

    
    // MARK: - Initialization
    
    init(_ textValue: String, isDeleteButton: Bool = false) {
        super.init(frame: .zero)
        
        self.textValue = textValue
        self.isDeleteButton = isDeleteButton
        
        setTitle(textValue, for: .normal)
        setTitleColor(UIColor(named: "menuBG"), for: .normal)
        titleLabel?.font = .secondo
        backgroundColor = UIColor(named: "menuTint")
        alpha = 0.5
        
        layer.cornerRadius = buttonSize / 2
        layer.shadowOffset = CGSize(width: buttonDepth, height: buttonDepth)
        layer.shadowRadius = buttonDepth
        layer.shadowOpacity = 0.5
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
        Haptics.playButtonTap()
        AudioPlayer.playSound(filename: TapSounds.sounds[isDeleteButton ? 0 : 2])
        
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
            self.layer.shadowOpacity = 0.5
        }, completion: completion)
    }
}
