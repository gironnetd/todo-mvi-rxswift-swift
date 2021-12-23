//
//  BaseViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 20/12/2021.
//

import UIKit
import MaterialComponents

class BaseViewController : UIViewController {

    lazy var materialAppbar : MDCAppBarViewController = MDCAppBarViewController()
    lazy var menuItem : UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func bindMaterialAppbar() {
        addChild(materialAppbar)
        
        MDCAppBarColorThemer.applyColorScheme(ApplicationScheme.shared.colorScheme, to: self.materialAppbar)
        MDCAppBarTypographyThemer.applyTypographyScheme(ApplicationScheme.shared.typographyScheme, to: self.materialAppbar)
        
        materialAppbar.inferTopSafeAreaInsetFromViewController = true
        
        // Match the width of the parent view.
        var frame = materialAppbar.view.frame;
        frame.origin.x = 0;
        frame.size.width = (materialAppbar.parent?.view.bounds.size.width)!;
        materialAppbar.view.frame = frame;
        
        view.addSubview(materialAppbar.view)
        materialAppbar.didMove(toParent: self)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func bindLeftBarButtonItem() {
        let menuItemImage = UIImage(named: "ic_arrow_back")
        let templatedMenuItemImage = menuItemImage?.withRenderingMode(.alwaysTemplate)
        menuItem = UIBarButtonItem(image: templatedMenuItemImage, style: .plain, target: nil, action: nil)
        
        menuItem.action = #selector(backPressed)
        
        self.navigationItem.leftBarButtonItem = menuItem
    }
    
    @objc func backPressed() {
        bindMenuItemBackPressed()
    }
    
    func bindMenuItemBackPressed() {
        preconditionFailure("This method must be overridden")
    }
}
