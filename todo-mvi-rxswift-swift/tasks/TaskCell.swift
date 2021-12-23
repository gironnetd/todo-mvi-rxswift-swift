//
//  TaskCell.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 13/12/2021.
//

import UIKit
import MaterialComponents

class TaskCell : UICollectionViewCell {
    
    @IBOutlet weak var completedBox: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var separatorLine: UIView!
    
    public var task : Task?
    
    var rippleView: MDCRippleView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func bind(task : Task) {
        self.task = task
        
        title.text = task.titleForList
        
        completedBox.isSelected = task.completed
        
        if(task.completed) {
            completedBox.tintColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        } else {
            completedBox.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        rippleView = MDCRippleView(frame: self.contentView.bounds)
        rippleView.rippleColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09803921569)
        self.contentView.addSubview(rippleView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        _ = contentView.rx.tapGesture().when(.ended).bind { [self] state in
            if(state.state == UIGestureRecognizer.State.ended) {
                (self.superview as! TasksCollectionView).taskClickSubject.on(.next(task!))
            }
        }
        
        completedBox.setImage(UIImage(named: "check_box_not_selected"), for: .normal)
        completedBox.setImage(UIImage(named: "check_box_selected"), for: .selected)
        
        contentView.bringSubviewToFront(completedBox)
        
        separatorLine.isHidden = true
        
        _ = completedBox.rx.tapGesture().when(.recognized).bind { [self] state in
            if(state.state == UIGestureRecognizer.State.ended) {
                task?.completed = !completedBox.isSelected
                completedBox.isSelected = !completedBox.isSelected
                
                if(completedBox.isSelected) {
                    completedBox.tintColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
                } else {
                    completedBox.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }
                (self.superview as! TasksCollectionView).taskToggleSubject.on(.next(task!))
            }
        }
    }
}
