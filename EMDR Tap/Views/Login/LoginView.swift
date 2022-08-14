//
//  LoginView.swift
//  EMDR Tap
//
//  Created by Eddie Char on 8/13/22.
//

import UIKit

protocol LoginViewDelegate: AnyObject {
    func didTapReturn(_ sessionID: Int)
}

class LoginView: UIView {
    
    // MARK: - Properties
    
    private let totalDigits: Int = 4
    private var sessionID = ""

    private var currentDigit = 0 {
        didSet {
            currentDigit = min(max(currentDigit, 0), totalDigits)
        }
    }

    private var statusLabel: UILabel!
    private var digitLabels: [DigitLabel]!
    
    private var button0: DigitButton!
    private var button1: DigitButton!
    private var button2: DigitButton!
    private var button3: DigitButton!
    private var button4: DigitButton!
    private var button5: DigitButton!
    private var button6: DigitButton!
    private var button7: DigitButton!
    private var button8: DigitButton!
    private var button9: DigitButton!
    private var buttonBackspace: DigitButton!
        
    lazy private var mainStack = UIStackView(arrangedSubviews: [labelStack, statusLabel, buttonStacks])
    lazy private var labelStack = UIStackView(arrangedSubviews: [UIView()] + digitLabels + [UIView()])
    lazy private var buttonStacks = UIStackView(arrangedSubviews: [buttonStack0, buttonStack1, buttonStack2, buttonStack3])
    lazy private var buttonStack0 = UIStackView(arrangedSubviews: [button7, button8, button9])
    lazy private var buttonStack1 = UIStackView(arrangedSubviews: [button4, button5, button6])
    lazy private var buttonStack2 = UIStackView(arrangedSubviews: [button1, button2, button3])
    lazy private var buttonStack3 = UIStackView(arrangedSubviews: [buttonBackspace, button0, UIView()])
    
    weak var delegate: LoginViewDelegate?

    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let stackSpacing: CGFloat = 10
        
        statusLabel = UILabel()
        statusLabel.text = "Enter Session ID"
        statusLabel.textColor = .white
        statusLabel.font = UIFont(name: "Georgia-Bold", size: 18)
        statusLabel.textAlignment = .center
        
        digitLabels = []
        for _ in 0..<totalDigits {
            digitLabels.append(DigitLabel())
        }

        button0 = DigitButton("0")
        button1 = DigitButton("1")
        button2 = DigitButton("2")
        button3 = DigitButton("3")
        button4 = DigitButton("4")
        button5 = DigitButton("5")
        button6 = DigitButton("6")
        button7 = DigitButton("7")
        button8 = DigitButton("8")
        button9 = DigitButton("9")
        buttonBackspace = DigitButton("←")
        
        button0.delegate = self
        button1.delegate = self
        button2.delegate = self
        button3.delegate = self
        button4.delegate = self
        button5.delegate = self
        button6.delegate = self
        button7.delegate = self
        button8.delegate = self
        button9.delegate = self
        buttonBackspace.delegate = self
                
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.spacing = stackSpacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually
        labelStack.spacing = stackSpacing
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        // The Button Stacks
        buttonStacks.axis = .vertical
        buttonStacks.distribution = .fillEqually
        buttonStacks.spacing = stackSpacing
        buttonStacks.translatesAutoresizingMaskIntoConstraints = false

        buttonStack0.axis = .horizontal
        buttonStack0.distribution = .fillEqually
        buttonStack0.spacing = stackSpacing
        buttonStack0.translatesAutoresizingMaskIntoConstraints = false

        buttonStack1.axis = .horizontal
        buttonStack1.distribution = .fillEqually
        buttonStack1.spacing = stackSpacing
        buttonStack1.translatesAutoresizingMaskIntoConstraints = false

        buttonStack2.axis = .horizontal
        buttonStack2.distribution = .fillEqually
        buttonStack2.spacing = stackSpacing
        buttonStack2.translatesAutoresizingMaskIntoConstraints = false

        buttonStack3.axis = .horizontal
        buttonStack3.distribution = .fillEqually
        buttonStack3.spacing = stackSpacing
        buttonStack3.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViews() {
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor),
                        
            digitLabels[0].heightAnchor.constraint(equalToConstant: button0.buttonSize * 2),
            
            button0.widthAnchor.constraint(equalToConstant: button0.buttonSize * 2),
            button0.heightAnchor.constraint(equalToConstant: button0.buttonSize)
        ])
    }
    
    
    // MARK: - Helper Functions
    
    func updateStatus(_ status: String) {
        statusLabel.text = status
        statusLabel.textColor = .systemRed
        statusLabel.alpha = 1.0
        
        UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
            self.statusLabel.alpha = 0.0
        }, completion: nil)
    }
}


// MARK: - DigitButtonDelegate

extension LoginView: DigitButtonDelegate {
    func didTapButton(_ sender: DigitButton) {
        if sender == buttonBackspace {
            currentDigit -= 1

            updateDigits(value: "", index: currentDigit)
            sessionID = "\(sessionID.dropLast())"
        }
        else {
            updateDigits(value: sender.textValue, index: currentDigit)
            sessionID += sender.textValue

            if currentDigit >= totalDigits - 1 {
                delegate?.didTapReturn(Int(sessionID) ?? 9999)
                print("sessionID: \(sessionID)")
                clearDigits(withDelay: true)
            }
            else {
                currentDigit += 1
            }
        }
    }
    
    private func updateDigits(value: String, index: Int) {
        digitLabels[index].setTextValue(value, withAnimation: value == "" ? true : false)
    }
    
    private func clearDigits(withDelay: Bool = false) {
        if withDelay {
            UIView.animate(withDuration: 2.25, delay: 0, options: [.curveEaseOut], animations: {
                self.labelStack.alpha = 0.5
                self.isUserInteractionEnabled = false
            }, completion: { _ in
                for (i, _) in self.digitLabels.enumerated() {
                    self.digitLabels[i].setTextValue("")
                }
                
                self.labelStack.alpha = 1.0
                self.isUserInteractionEnabled = true
            })
        }
        else {
            for (i, _) in self.digitLabels.enumerated() {
                self.digitLabels[i].setTextValue("", withAnimation: i < self.currentDigit ? true : false)
            }
        }
        
        currentDigit = 0
        sessionID = ""
    }
}
