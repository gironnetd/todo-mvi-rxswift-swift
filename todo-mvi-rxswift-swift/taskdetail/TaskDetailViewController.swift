//
//  TaskDetailViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 01/12/2021.
//

import UIKit
import MaterialComponents
import RxSwift
import RxCocoa
import RxGesture

extension TaskDetailViewController: MviView {
    
    typealias Intent = EnumTaskDetailIntent
    typealias ViewState = TaskDetailViewState
    
    func intents() -> Observable<Intent> {
        return Observable.merge(initialIntent(), checkBoxIntents(), deleteIntent())
    }
    
    func render(state: ViewState) {
        setLoadingIndicator(active: state.loading)
        
        if (!state.title.isEmpty) {
            showTitle(title: state.title)
        } else {
            hideTitle()
        }
        
        if (!state.description.isEmpty) {
            showDescription(description: state.description)
        } else {
            hideDescription()
        }
        
        showActive(isActive: state.active)
        
        switch (state.uiNotification) {
        case .TASK_COMPLETE : showTaskMarkedComplete()
        case .TASK_ACTIVATED : showTaskMarkedActive()
        case .TASK_DELETED : self.dismiss(animated: false, completion: nil)
        case .none:
            break
        }
    }
    
    /**
     * The initial Intent the [MviView] emit to convey to the [MviViewModel]
     * that it is ready to receive data.
     * This initial Intent is also used to pass any parameters the [MviViewModel] might need
     * to render the initial [MviViewState] (e.g. the task id to load).
     */
    private func initialIntent() -> Observable<Intent> {
        return Observable.just(.InitialIntent(TaskDetailIntent.InitialIntent(taskId: argumentTaskId!)))
    }
    
    private func checkBoxIntents() -> Observable<Intent> {
        return detailCompleteStatus.rx.tapGesture().when(.ended).map { [self]_ in
            detailCompleteStatus.isSelected = !detailCompleteStatus.isSelected
            
            if(detailCompleteStatus.isSelected) {
                detailCompleteStatus.tintColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
                return .CompleteTaskIntent(TaskDetailIntent.CompleteTaskIntent(taskId: argumentTaskId!))
            } else {
                detailCompleteStatus.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                return .ActivateTaskIntent(TaskDetailIntent.ActivateTaskIntent(taskId: argumentTaskId!))
            }
        }
    }
    
    private func deleteIntent() -> Observable<Intent> {
        return deleteTaskIntentPublisher.flatMap { intent in
            return Observable.just(Intent.DeleteTask(intent))
        }
    }
    
    func setLoadingIndicator(active: Bool) {
        if (active) {
            detailTitle.text = ""
            detailDescription.text = NSLocalizedString("loading", comment: "")
        }
    }
    
    func hideDescription() {
        detailDescription.isHidden = true
    }
    
    func hideTitle() {
        detailTitle.isHidden = true
    }
    
    func showActive(isActive: Bool) {
        detailCompleteStatus.isSelected = !isActive
        
        if(detailCompleteStatus.isSelected) {
            detailCompleteStatus.tintColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        } else {
            detailCompleteStatus.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func showDescription(description: String) {
        detailDescription.isHidden = false
        detailDescription.text = description
    }
    
    private func showEditTask(taskId: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addEditTaskViewController = storyBoard.instantiateViewController(withIdentifier: "AddEditTaskViewController") as! AddEditTaskViewController
        addEditTaskViewController.argumentTaskId = taskId
        addEditTaskViewController.modalPresentationStyle = .fullScreen
        self.present(addEditTaskViewController, animated: true, completion: nil)
    }
    
    func showTaskMarkedComplete() {
        let snackBar = MDCSnackbarMessage()
        snackBar.text = NSLocalizedString("task_marked_complete", comment: "")
        snackBar.duration = 1.5
        MDCSnackbarManager.default.show(snackBar)
    }
    
    func showTaskMarkedActive() {
        let snackBar = MDCSnackbarMessage()
        snackBar.text = NSLocalizedString("task_marked_active", comment: "")
        snackBar.duration = 1.5
        MDCSnackbarManager.default.show(snackBar)
    }
    
    func showTitle(title: String) {
        detailTitle.isHidden = false
        detailTitle.text = title
    }
}

class TaskDetailViewController : BaseViewController {
    
    @IBOutlet weak var detailCompleteStatus: UIButton!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailDescription: UILabel!
    
    lazy var floatingActionButton : MDCFloatingButton = MDCFloatingButton(shape: .default)
    
    // Used to manage the data flow lifecycle and avoid memory leak.
    lazy var disposables: CompositeDisposable = CompositeDisposable()
    private let deleteTaskIntentPublisher = PublishSubject<TaskDetailIntent.DeleteTaskIntent>()
    
    private lazy var viewModel : TaskDetailViewModel = TaskDetailViewModel()

    var argumentTaskId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindMaterialAppbar()
        bindFloatingActionButton()
        bind()
        // Do any additional setup after loading the view.
        
        detailCompleteStatus.setImage(UIImage(named: "check_box_not_selected"), for: .normal)
        detailCompleteStatus.setImage(UIImage(named: "check_box_selected"), for: .selected)
        
        if(detailCompleteStatus.isSelected) {
            detailCompleteStatus.tintColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        } else {
            detailCompleteStatus.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
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
    }
    
    override func bindMenuItemBackPressed() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tasksViewController = storyBoard.instantiateViewController(withIdentifier: "TasksViewController") as! TasksViewController
        tasksViewController.modalPresentationStyle = .fullScreen
        self.present(tasksViewController, animated: false, completion: nil)
    }
    
    override func bindMaterialAppbar() {
        super.bindMaterialAppbar()
        
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
        
        let deletTtaskItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
        deletTtaskItem.title = NSLocalizedString("menu_delete_task", comment: "")
        
        deletTtaskItem.action = #selector(action)
        
        self.navigationItem.rightBarButtonItems = [ deletTtaskItem]
    }
    
    @objc func action (sender:UIButton) {
        deleteTaskIntentPublisher.on(.next(TaskDetailIntent.DeleteTaskIntent(taskId: argumentTaskId!)))
    }
    
    private func bindFloatingActionButton() {
        floatingActionButton.sizeToFit()
        floatingActionButton.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        floatingActionButton.setImage(UIImage(named: "edit"), for: .normal)
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
        
        _ = disposables.insert(floatingActionButton.rx.tapGesture().when(.ended).bind { [self] state in
            if(state.state == UIGestureRecognizer.State.ended) {
                showEditTask(taskId: argumentTaskId!)
            }
        })
    }
    
    deinit {
        disposables.dispose()
    }
}
