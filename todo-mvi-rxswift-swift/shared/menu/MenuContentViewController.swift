//
//  MenuContentViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 20/12/2021.
//

import Foundation
import UIKit
import MaterialComponents.MaterialBottomNavigation

protocol MenuContentViewClickListener {
    func onClickLinstener(indexPath: IndexPath)
}

public class MenuContentViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var bottomDrawerViewController: MDCBottomDrawerViewController!
    
    private var callBack : MenuContentViewClickListener?
    
    func setCallbackListener(listener : MenuContentViewClickListener) {
        self.callBack = listener
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let layout = UICollectionViewFlowLayout()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.frame = CGRect(
            x: 0, y: 0, width: self.view.bounds.width,
            height: self.view.bounds.height)
        collectionView.delegate = self
        collectionView.dataSource = self
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.layoutMargins.top = 24
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: 150)
        self.preferredContentSize = CGSize(
            width: view.frame.width,
            height: layout.collectionViewContentSize.height + 150)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath)  as! MenuCell
        
        switch indexPath.item {
        case 0:
            cell.menuTitle.text = NSLocalizedString("list_title", comment: "")
            cell.menuIcon.image = UIImage(named: "ic_list")
        case 1:
            cell.menuTitle.text = NSLocalizedString("statistics_title", comment: "")
            cell.menuIcon.image = UIImage(named: "ic_statistics")
        default:
            break
        }
        
        _ = cell.contentView.rx.tapGesture().when(.ended).bind { state in
            if(state.state == UIGestureRecognizer.State.ended) {
                self.callBack?.onClickLinstener(indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
