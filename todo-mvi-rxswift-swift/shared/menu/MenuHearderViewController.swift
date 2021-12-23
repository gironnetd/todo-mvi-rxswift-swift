//
//  DrawerContentViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 18/12/2021.
//

import UIKit
import MaterialComponents

class MenuHearderViewController : UIViewController, MDCBottomDrawerHeader {
    let preferredHeight: CGFloat = 192
    
    lazy var logo: UIImageView = {
        let image = UIImageView(image: UIImage(named: "logo"))
        return image
    }()
    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("navigation_view_header_title", comment: "")
        label.font = UIFont(name: "Roboto-Regular", size: 17)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.accessibilityTraits = .header
        label.sizeToFit()
        return label
    }()
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: view.bounds.width, height: preferredHeight)
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logo)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logo.centerXAnchor.constraint(lessThanOrEqualTo: logo.superview!.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(lessThanOrEqualTo: logo.superview!.centerYAnchor).isActive = true
        
        view.addSubview(headerTitle)
        
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.centerXAnchor.constraint(lessThanOrEqualTo: logo.centerXAnchor).isActive = true
        headerTitle.topAnchor.constraint(lessThanOrEqualTo: logo.bottomAnchor, constant: 8).isActive = true
    }
}
