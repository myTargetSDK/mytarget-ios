//
//  NativeSettingsViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 18.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class NativeSettingsViewController: UIViewController {
    
    private enum RadioButtons: String, CaseIterable {
        case promo = "Promo"
        case video = "Video"
        case cards = "Cards"
    }
    
    private lazy var radioButtons: RadioButtonsView<RadioButtons> = .init(title: "View type")
    private lazy var showButton: CustomButton = .init(title: "Show")
    
    private let radioButtonsInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    private let showButtonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16)
    private let buttonHeight: CGFloat = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Native Ads settings"
        
        view.backgroundColor = .backgroundColor()
        view.addSubview(radioButtons)
        view.addSubview(showButton)
        
        showButton.addTarget(self, action: #selector(showButtonTap(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = supportSafeAreaInsets
        let radioButtonsWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - radioButtonsInsets.left - radioButtonsInsets.right
        let radioButtonsHeight = radioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
        radioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
                                    y: safeAreaInsets.top + radioButtonsInsets.top,
                                    width: radioButtonsWidth,
                                    height: radioButtonsHeight)

        showButton.frame = CGRect(x: safeAreaInsets.left + showButtonInsets.left,
                                  y: radioButtons.frame.maxY + radioButtonsInsets.bottom + showButtonInsets.top,
                                  width: view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - showButtonInsets.left - showButtonInsets.right,
                                  height: buttonHeight)
    }
    
    // MARK: - Actions
    
    @objc private func showButtonTap(_ sender: CustomButton) {
        let slot: Slot
        switch radioButtons.selectedRadioButtonType {
        case .promo:
            slot = Slot.nativePromo
        case .video:
            slot = Slot.nativeVideo
        case .cards:
            slot = Slot.nativeCards
        }
        
        let viewController = NativeViewController(slotId: slot.id)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
