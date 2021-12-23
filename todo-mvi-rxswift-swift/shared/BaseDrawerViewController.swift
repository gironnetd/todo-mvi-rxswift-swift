//
//  BaseDrawerViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 21/12/2021.
//

import UIKit
import MaterialComponents

class BaseDrawerViewController : BaseViewController {
    
    let headerViewController = MenuHearderViewController()
    lazy var bottomDrawerViewController : MDCBottomDrawerViewController = MDCBottomDrawerViewController()
    lazy var menuContentViewController : MenuContentViewController = {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuContentViewController = storyBoard.instantiateViewController(withIdentifier: "MenuContentViewController") as! MenuContentViewController
        
        return menuContentViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func bindLeftBarButtonItem() {
        let menuItemImage = UIImage(named: "menu")
        let templatedMenuItemImage = menuItemImage?.withRenderingMode(.alwaysTemplate)
        menuItem = UIBarButtonItem(image: templatedMenuItemImage, style: .plain, target: nil, action: nil)
        
        menuItem.action = #selector(presentNavigationDrawer)
        
        self.navigationItem.leftBarButtonItem = menuItem
    }
    
    @objc public func presentNavigationDrawer() {
        
        bottomDrawerViewController.contentViewController = menuContentViewController
        menuContentViewController.bottomDrawerViewController = bottomDrawerViewController
        
        bottomDrawerViewController.setTopCornersRadius(16.0, for: MDCBottomDrawerState.expanded)
        bottomDrawerViewController.setTopCornersRadius(16.0, for: MDCBottomDrawerState.fullScreen)
        bottomDrawerViewController.setTopCornersRadius(16.0, for: MDCBottomDrawerState.collapsed)
        
        bottomDrawerViewController.trackingScrollView = menuContentViewController.collectionView
        
        bottomDrawerViewController.headerViewController = headerViewController
        
        bottomDrawerViewController.headerViewController?.view.backgroundColor = ApplicationScheme.shared.colorScheme.primaryColor
        bottomDrawerViewController.contentViewController?.view.backgroundColor =
            ApplicationScheme.shared.colorScheme.surfaceColor
        bottomDrawerViewController.scrimColor = ApplicationScheme.shared.colorScheme.onSurfaceColor.withAlphaComponent(0.32)
        
        present(bottomDrawerViewController, animated: true, completion: { [self] in
            
            bottomDrawerViewController.trackingScrollView?.isScrollEnabled = false
            bottomDrawerViewController.maximumDrawerHeight =
                (bottomDrawerViewController.contentViewController?.preferredContentSize.height)! +
                (bottomDrawerViewController.headerViewController?.preferredContentSize.height)!
            bottomDrawerViewController.maximumInitialDrawerHeight = (bottomDrawerViewController.contentViewController?.preferredContentSize.height)! +
                (bottomDrawerViewController.headerViewController?.preferredContentSize.height)!
            bindMenuItemAction()
        })
    }
    
    func bindMenuItemAction() {
        preconditionFailure("This method must be overridden")
    }
}



