//
//  MenuButton.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/8/22.
//

import UIKit

protocol MenuButtonDelegate: AnyObject {
    func didTapButton(_ sender: UIButton)
}


class MenuButton: UIButton {
    
    // MARK: - Properties
    
    private let buttonDepth: CGFloat = 3
    private var buttonTitle: String!
    weak var delegate: MenuButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(title: String) {
        super.init(frame: .zero)

        buttonTitle = title

        setTitle(buttonTitle, for: .normal)
        titleLabel?.font = .primo
        setTitleColor(UIColor(named: "menuTint"), for: .normal)
        backgroundColor = .clear
        
        layer.borderWidth = 4
        layer.borderColor = UIColor(named: "menuTint")!.cgColor
        layer.shadowOffset = CGSize(width: buttonDepth, height: buttonDepth)
        layer.shadowRadius = buttonDepth
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 12
        
        clipsToBounds = true
        layer.masksToBounds = false
        addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonTouchDragExit(_:)), for: .touchDragExit)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        Haptics.playMenuButtonTap()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.transform = CGAffineTransform(translationX: self.buttonDepth, y: self.buttonDepth)
            self.layer.shadowOpacity = 0
        }, completion: nil)
    }
    
    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        animateTouchUp(completion: { _ in
            self.delegate?.didTapButton(sender)
        })
    }
    
    @objc private func buttonTouchDragExit(_ sender: UIButton) {
        animateTouchUp(completion: nil)
    }
    
    private func animateTouchUp(completion: ((Bool) -> ())?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
            self.layer.shadowOpacity = 0.5
        }, completion: completion)
    }
}
