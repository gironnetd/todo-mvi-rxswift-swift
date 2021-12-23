//
//  StatisticsViewController.swift
//  todo-mvi-rxswift-swift
//
//  Created by damien on 01/12/2021.
//

import UIKit
import MaterialComponents
import RxSwift
import RxCocoa
import RxGesture

extension AddEditTaskViewController: MviView {
    
    typealias Intent = EnumAddEditTaskIntent
    typealias ViewState = AddEditTaskViewState
    
    func intents() -> Observable<Intent> {
        return Observable.merge(initialIntent(), saveTaskIntent())
    }
    
    private func initialIntent() -> Observable<Intent> {
        return Observable.just(Intent.InitialIntent(AddEditTaskIntent.InitialIntent(taskId: argumentTaskId)))
    }
    
    private func saveTaskIntent() -> Observable<Intent> {
        // Wrap the FAB click events into a SaveTaskIntent and set required information
        return floatingActionButton.rx.tapGesture().when(.ended).map { [self]_ in
            return .SaveTask(AddEditTaskIntent.SaveTaskIntent(
                taskId: argumentTaskId,
                title: taskTitle.text ?? "",
                description: taskDescription.text ?? ""
            ))
        }
    }
    
    func render(state: ViewState) {
        if (state.isSaved) {
            showTasksList()
            return
        }
        if (state.isEmpty) {
            showEmptyTaskError()
        }
        if (!state.title.isEmpty) {
            setTitle(title: state.title)
        }
        if (!state.description.isEmpty) {
            setDescription(description: state.description)
        }
    }
    
    private func showEmptyTaskError() {
        let snackBar = MDCSnackbarMessage()
        snackBar.text = NSLocalizedString("empty_task_message", comment: "")
        snackBar.duration = 1.5
        MDCSnackbarManager.default.show(snackBar)
    }
    
    private func showTasksList() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tasksViewController = storyBoard.instantiateViewController(withIdentifier: "TasksViewController") as! TasksViewController
        tasksViewController.modalPresentationStyle = .fullScreen
        self.present(tasksViewController, animated: false, completion: nil)
    }
    
    private func setTitle(title: String) {
        self.taskTitle.text = title
    }
    
    private func setDescription(description: String) {
        self.taskDescription.text = description
    }
}

class AddEditTaskViewController: BaseViewController {
    
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var taskDescription: UITextField!
    
    lazy var floatingActionButton : MDCFloatingButton = MDCFloatingButton(shape: .default)
    
    // Used to manage the data flow lifecycle and avoid memory leak.
    lazy var disposables: CompositeDisposable = CompositeDisposable()
    
    private lazy var viewModel : AddEditTaskViewModel = AddEditTaskViewModel()
    
    var argumentTaskId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindMaterialAppbar()
        bindFloatingActionButton()
        bind()
        // Do any additional setup after loading the view.
    }
    
    override func bindMenuItemBackPressed() {
        if(argumentTaskId != nil) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let taskDetailViewController = storyBoard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
            taskDetailViewController.argumentTaskId = argumentTaskId
            taskDetailViewController.modalPresentationStyle = .fullScreen
            self.present(taskDetailViewController, animated: false, completion: nil)
        } else {
            showTasksList()
        }
        
    }
    
    override func bindMaterialAppbar() {
        super.bindMaterialAppbar()
        
        let materailAppbarTitle = UILabel()
        materailAppbarTitle.text = NSLocalizedString("add_task", comment: "")
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
    
    deinit {
        disposables.dispose()
    }
}

