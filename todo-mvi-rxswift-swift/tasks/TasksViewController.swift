//
//  TasksViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 01/12/2021.
//

import UIKit
import MaterialComponents
import RxSwift
import RxCocoa
import RxGesture

extension TasksViewController: MviView {
    
    typealias Intent = EnumTasksIntent
    typealias ViewState = TasksViewState
    
    func intents() -> Observable<Intent> {
        return Observable.merge(
            Observable.merge(
                initialIntent(),
                refreshIntent(),
                adapterIntents(),
                clearCompletedTaskIntent()
            ),
            changeFilterIntent()
        )
    }
    
    func render(state: ViewState) {
        if (state.error != nil) {
            showLoadingTasksError()
            return
        }
        
        switch (state.uiNotification) {
        case .TASK_COMPLETE : showMessage(message: NSLocalizedString("task_marked_complete", comment: ""))
        case .TASK_ACTIVATED : showMessage(message: NSLocalizedString("task_marked_active", comment: ""))
        case .COMPLETE_TASKS_CLEARED : showMessage(message: NSLocalizedString("completed_tasks_cleared", comment: ""))
        case .none:
            break
        }
        
        if (state.tasks.isEmpty) {
            switch (state.tasksFilterType) {
            case .ACTIVE_TASKS : showNoActiveTasks()
            case .COMPLETED_TASKS : showNoCompletedTasks()
            default :
                showNoTasks()
            }
        } else {
            tasksCollectionView.replaceData(tasks: state.tasks.sorted(by: { $0.titleForList < $1.titleForList }))
            
            tasksCollectionView.isHidden = false
            noTasksView.isHidden = true
            
            switch (state.tasksFilterType) {
            case .ACTIVE_TASKS : showActiveFilterLabel()
            case .COMPLETED_TASKS : showCompletedFilterLabel()
            default :
                showAllFilterLabel()
            }
        }
    }
    
    private func showMessage(message : String) {
        let snackBar = MDCSnackbarMessage()
        snackBar.text = message
        snackBar.duration = 1.5
        MDCSnackbarManager.default.show(snackBar)
    }
    
    private func initialIntent() -> Observable<Intent> {
        return Observable.just(.InitialIntent)
    }
    
    private func refreshIntent() -> Observable<Intent> {
        return refreshIntentPublisher.flatMap { intent in
            return Observable.just(.RefreshIntent(intent))
        }
    }
    
    private func clearCompletedTaskIntent() -> Observable<Intent> {
        return clearCompletedTaskIntentPublisher.flatMap {_ in
            return Observable.just(.ClearCompletedTasksIntent)
        }
    }
    
    private func changeFilterIntent() -> Observable<Intent> {
        return changeFilterIntentPublisher.flatMap { intent in
            return Observable.just(.ChangeFilterIntent(intent))
        }
    }
    
    private func adapterIntents() -> Observable<Intent> {
        return tasksCollectionView.taskToggleObservable.map { task in
            if(task.completed) {
                return .CompleteTaskIntent(.init(task: task))
            } else {
                return .ActivateTaskIntent(.init(task: task))
            }
        }
    }
    
    private func showActiveFilterLabel() {
        tasksCollectionView.hearderView?.filteringLabel.text = NSLocalizedString("label_active", comment: "")
    }
    
    private func showCompletedFilterLabel() {
        tasksCollectionView.hearderView?.filteringLabel.text = NSLocalizedString("label_completed", comment: "")
    }
    
    private func showAllFilterLabel() {
        tasksCollectionView.hearderView?.filteringLabel.text = NSLocalizedString("label_all", comment: "")
    }
    
    private func showNoActiveTasks() {
        showNoTasksViews(
            mainText: "no_tasks_active",
            iconRes: "ic_check_circle_24dp",
            showAddView: false
        )
    }
    
    private func showNoTasks() {
        showNoTasksViews(
            mainText: "no_tasks_all",
            iconRes: "ic_assignment_turned_in_24pt",
            showAddView: true
        )
    }
    
    private func showNoCompletedTasks() {
        showNoTasksViews(
            mainText: "no_tasks_completed",
            iconRes: "ic_verified_user_24dp",
            showAddView: false
        )
    }
    
    private func showNoTasksViews(
        mainText: String,
        iconRes: String,
        showAddView: Bool
    ) {
        tasksCollectionView.isHidden = true
        noTasksView.isHidden = false
        noTasksMain.text = NSLocalizedString(mainText, comment: "")
        noTasksAdd.isHidden = !showAddView
    }
}

extension TasksViewController : MenuContentViewClickListener {
    
    func onClickLinstener(indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            self.bottomDrawerViewController.dismiss(animated: true, completion: nil)
        case 1:
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let statisticsViewController = storyBoard.instantiateViewController(withIdentifier: "StatisticsViewController") as! StatisticsViewController
            statisticsViewController.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true, completion: nil)
            self.present(statisticsViewController, animated: false, completion: nil)
        default:
            break
        }
    }
}

class TasksViewController: BaseDrawerViewController   {
    
    @IBOutlet weak var tasksCollectionView : TasksCollectionView!
    
    @IBOutlet weak var noTasksView : UIView!
    @IBOutlet weak var noTasksIcon : UIImageView!
    @IBOutlet weak var noTasksMain : UILabel!
    @IBOutlet weak var noTasksAdd : UILabel!
    
    private let refreshIntentPublisher: PublishSubject = PublishSubject<TasksIntent.RefreshIntent>()
    private let clearCompletedTaskIntentPublisher = PublishSubject<TasksIntent.ClearCompletedTasksIntent>()
    private let changeFilterIntentPublisher = PublishSubject<TasksIntent.ChangeFilterIntent>()
    // Used to manage the data flow lifecycle and avoid memory leak.
    lazy var disposables: CompositeDisposable = CompositeDisposable()
    
    private lazy var viewModel : TasksViewModel = TasksViewModel()
    
    lazy var floatingActionButton : MDCFloatingButton = MDCFloatingButton(shape: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindMaterialAppbar()
        bindFloatingActionButton()
        bindNoTasksView()
        bind()
    }
    
    /**
     * Connect the [MviView] with the [MviViewModel]
     * We subscribe to the [MviViewModel] before passing it the [MviView]'s [MviIntent]s.
     * If we were to pass [MviIntent]s to the [MviViewModel] before listening to it,
     * emitted [MviViewState]s could be lost
     */
    private func bind() {
        // Subscribe to the ViewModel and call render for every emitted state
        _ = disposables.insert(viewModel.states().subscribe(onNext: render))
        
        // Pass the UI's intents to the ViewModel
        viewModel.processIntents(intents: intents())
        
        _ = disposables.insert(
            tasksCollectionView.taskClickObservable.subscribe { task in
                self.showTaskDetailsUi(taskId: task.id)
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshIntentPublisher.on(.next(TasksIntent.RefreshIntent(forceUpdate: false)))
    }
    
    private func bindNoTasksView() {
        noTasksMain.text = NSLocalizedString("no_tasks_all", comment: "")
        noTasksAdd.text = NSLocalizedString("no_tasks_add", comment: "")
        
        _ = disposables.insert(noTasksAdd.rx.tapGesture().when(.ended).bind { state in
            if(state.state == UIGestureRecognizer.State.ended) {
                self.showAddTask()
            }
        })
    }
    
    override func bindMenuItemAction() {
        (bottomDrawerViewController.contentViewController as! MenuContentViewController).setCallbackListener(listener: self)
    }
    
    override func bindMaterialAppbar() {
        super.bindMaterialAppbar()
        materialAppbar.headerView.trackingScrollView = self.tasksCollectionView
        
        let materailAppbarTitle = UILabel()
        materailAppbarTitle.text = NSLocalizedString("app_name", comment: "")
        materailAppbarTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        materailAppbarTitle.textAlignment = .left
        materailAppbarTitle.textColor = UIColor.white
        self.navigationItem.titleView = materailAppbarTitle
        materailAppbarTitle.translatesAutoresizingMaskIntoConstraints = false
        materailAppbarTitle.superview?.addConstraint(NSLayoutConstraint(item: materailAppbarTitle, attribute: .centerX, relatedBy: .equal, toItem: materailAppbarTitle.superview, attribute: .centerX, multiplier: 1, constant: 0))
        materailAppbarTitle.superview?.addConstraint(NSLayoutConstraint(item: materailAppbarTitle, attribute: .width, relatedBy: .equal, toItem: materailAppbarTitle.superview, attribute: .width, multiplier: 1, constant: 0))
        materailAppbarTitle.superview?.addConstraint(NSLayoutConstraint(item: materailAppbarTitle, attribute: .centerY, relatedBy: .equal, toItem: materailAppbarTitle.superview, attribute: .centerY, multiplier: 1, constant: 0))
        materailAppbarTitle.superview?.addConstraint(NSLayoutConstraint(item: materailAppbarTitle, attribute: .height, relatedBy: .equal, toItem: materailAppbarTitle.superview, attribute: .height, multiplier: 1, constant: 0))
        
        bindLeftBarButtonItem()
        
        let filterItemImage = UIImage(named: "filter_list")
        let templatedSearchItemImage = filterItemImage?.withRenderingMode(.alwaysTemplate)
        let filterItem = UIBarButtonItem(image: templatedSearchItemImage,style: .plain,target: nil, action: nil)
        
        let allAction = UIAction(title: NSLocalizedString("nav_all", comment: ""), image: nil) { action in
            self.changeFilterIntentPublisher.on(.next(TasksIntent.ChangeFilterIntent(filterType: .ALL_TASKS)))
        }
        let activeAction = UIAction(title: NSLocalizedString("nav_active", comment: ""), image: nil) { action in
            self.changeFilterIntentPublisher.on(.next(TasksIntent.ChangeFilterIntent(filterType: .ACTIVE_TASKS)))
        }
        let completedAction = UIAction(title: NSLocalizedString("nav_completed", comment: ""), image: nil) { action in
            self.changeFilterIntentPublisher.on(.next(TasksIntent.ChangeFilterIntent(filterType: .COMPLETED_TASKS)))
        }
        
        filterItem.primaryAction = nil
        filterItem.menu = UIMenu(title: "", children: [allAction, activeAction, completedAction])
        
        let tasksItemImage = UIImage(named: "more_vert")
        let templatedTuneItemImage = tasksItemImage?.withRenderingMode(.alwaysTemplate)
        let tasksItem = UIBarButtonItem(image: templatedTuneItemImage, style: .plain, target: nil, action: nil)
        
        let clearCompletedAction = UIAction(title: NSLocalizedString("menu_clear", comment: ""), image: nil) { action in
            self.clearCompletedTaskIntentPublisher.on(.next(TasksIntent.ClearCompletedTasksIntent()))
        }
        let refreshAction = UIAction(title: NSLocalizedString("refresh", comment: ""), image: nil) { action in
            self.refreshIntentPublisher.on(.next(TasksIntent.RefreshIntent(forceUpdate: true)))
        }
        
        tasksItem.primaryAction = nil
        tasksItem.menu = UIMenu(title: "", children: [clearCompletedAction, refreshAction])
        
        self.navigationItem.rightBarButtonItems = [ tasksItem, filterItem ]
    }
    
    private func bindFloatingActionButton() {
        floatingActionButton.sizeToFit()
        floatingActionButton.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        floatingActionButton.setImage(UIImage(named: "ic_add"), for: .normal)
        floatingActionButton.setImageTintColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        
        view.addSubview(floatingActionButton)
        
        floatingActionButton.minimumSize = CGSize(width: 64, height: 48)
        
        floatingActionButton.translatesAutoresizingMaskIntoConstraints = false
        floatingActionButton.centerVisibleArea = true
        
        NSLayoutConstraint.activate(
            [
                floatingActionButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
                floatingActionButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24)
            ]
        )
        
        _ = disposables.insert(floatingActionButton.rx.tapGesture().when(.ended).bind { state in
            if(state.state == UIGestureRecognizer.State.ended) {
                self.showAddTask()
            }
        })
    }
    
    private func showAddTask() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addEditTaskViewController = storyBoard.instantiateViewController(withIdentifier: "AddEditTaskViewController") as! AddEditTaskViewController
        addEditTaskViewController.modalPresentationStyle = .fullScreen
        self.present(addEditTaskViewController, animated: false, completion: nil)
    }
    
    private func showTaskDetailsUi(taskId : String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let taskDetailViewController = storyBoard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        taskDetailViewController.argumentTaskId = taskId
        taskDetailViewController.modalPresentationStyle = .fullScreen
        self.present(taskDetailViewController, animated: false, completion: nil)
    }
    
    private func showLoadingTasksError() {
        showMessage(message: NSLocalizedString("loading_tasks_error", comment: ""))
    }
    
    deinit {
        disposables.dispose()
    }
}
