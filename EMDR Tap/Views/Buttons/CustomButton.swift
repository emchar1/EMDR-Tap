//
//  CustomButton.swift
//  EMDR Tap
//
//  Created by Eddie Char on 7/23/22.
//

import UIKit

protocol CustomButtonDelegate: AnyObject {
    func didTapButton(_ button: CustomButton)
}

class CustomButton: UIButton {
    
    // MARK: - Properties
    
    private let buttonDepth: CGFloat = 2
    private var shouldAnimatePress: Bool = false
    weak var delegate: CustomButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(image: UIImage?, asTemplate: Bool = true, shouldAnimatePress: Bool = false) {
        super.init(frame: .zero)
        
        self.shouldAnimatePress = shouldAnimatePress
                
        switch DataService.sessionType {
        case .guest: tintColor = UIColor(named: "guestTint")
        case .host: tintColor = UIColor(named: "hostTint")
        default: tintColor = UIColor(named: "localTint")
        }

        setImage(image?.withRenderingMode(asTemplate ? .alwaysTemplate : .alwaysOriginal), for: .normal)

        layer.shadowRadius = buttonDepth
        layer.shadowOffset = CGSize(width: buttonDepth, height: buttonDepth)
        layer.shadowOpacity = 0.5

        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
        translatesAutoresizingMaskIntoConstraints = false

        addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(buttonTouchDragExit(_:)), for: .touchDragExit)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    @objc private func buttonTouchDown(_ sender: CustomButton) {
        guard shouldAnimatePress else { return }
        
        Haptics.playCustomButtonTap()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(translationX: self.buttonDepth, y: self.buttonDepth)
            self.layer.shadowOpacity = 0
        })
    }
    
    @objc private func buttonTouchUpInside(_ sender: CustomButton) {
        if shouldAnimatePress {
            animateTouchUp(completion: { _ in
                self.delegate?.didTapButton(sender)
            })
        }
        else {
            delegate?.didTapButton(sender)
        }
    }
    
    @objc private func buttonTouchDragExit(_ sender: CustomButton) {
        guard shouldAnimatePress else { return }
        
        animateTouchUp(completion: nil)
    }
    
    private func animateTouchUp(completion: ((Bool) -> ())?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
            self.layer.shadowOpacity = 0.5
        }, completion: completion)
    }
}
