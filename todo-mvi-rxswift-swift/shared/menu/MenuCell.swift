//
//  MenuCell.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 18/12/2021.
//

import UIKit

//@IBDesignable
class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
