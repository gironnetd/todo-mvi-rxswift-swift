//
//  TasksCollectionView.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 13/12/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import MaterialComponents

class TasksCollectionView : UICollectionView,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MDCRippleTouchControllerDelegate
{
    
    public let taskClickSubject = PublishSubject<Task>()
    public let taskToggleSubject = PublishSubject<Task>()
    lazy var disposables: CompositeDisposable = CompositeDisposable()
    
    var taskClickObservable: Observable<Task> {
        return taskClickSubject
    }
    
    var taskToggleObservable: Observable<Task> {
        return taskToggleSubject
    }
    
    var hearderView: TasksCollectionHeaderView!
    
    var rippleTouchController: MDCRippleTouchController?
    @objc var containerScheme: MDCContainerScheming!
    
    lazy var tasks: [Task] = [Task]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.contentInsetAdjustmentBehavior = .never
        self.delaysContentTouches = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.allowsMultipleSelection = true
        containerScheme = MDCContainerScheme()
        
        rippleTouchController = MDCRippleTouchController(view: self)
        rippleTouchController?.delegate = self
    }
    
    public func replaceData(tasks: [Task]) {
        self.tasks = tasks
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as! TaskCell
    
        cell.bind(task: tasks[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
              withReuseIdentifier: "TasksCollectionHeaderView",
              for: indexPath) as! TasksCollectionHeaderView
        
        self.hearderView = headerView
        return headerView
    }
    
    func rippleTouchController(_ rippleTouchController: MDCRippleTouchController, rippleViewAtTouchLocation location: CGPoint
    ) -> MDCRippleView? {
        guard let indexPath = self.indexPathForItem(at: location) else {
            return nil
        }
        let cell = self.cellForItem(at: indexPath) as? TaskCell
        if let cell = cell {
            return cell.rippleView
        }
        return nil
    }
}

class TasksCollectionHeaderView : UICollectionReusableView {
    @IBOutlet weak var filteringLabel: UILabel!
}
