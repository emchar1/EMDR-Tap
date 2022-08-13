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
    private var button: UIButton!
    private var buttonTitle: String
    weak var delegate: MenuButtonDelegate?
    
    
    // MARK: - Initialization
    
    init(title: String) {
        buttonTitle = title
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "Georgia-Bold", size: 20)
        button.setTitleColor(UIColor(named: "buttonMenuColor"), for: .normal)
        button.backgroundColor = .clear
        
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor(named: "buttonMenuColor")!.cgColor
        button.layer.shadowOffset = CGSize(width: buttonDepth, height: buttonDepth)
        button.layer.shadowRadius = buttonDepth
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = 12
        
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDragExit(_:)), for: .touchDragExit)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: button.trailingAnchor),
            bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
    }
    
    
    // MARK: - Helper Functions
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.button.transform = CGAffineTransform(translationX: self.buttonDepth, y: self.buttonDepth)
            self.button.layer.shadowOpacity = 0
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
            self.button.transform = CGAffineTransform(translationX: 0, y: 0)
            self.button.layer.shadowOpacity = 0.5
        }, completion: completion)
    }
}
