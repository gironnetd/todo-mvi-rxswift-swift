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

extension StatisticsViewController: MviView {
    
    typealias Intent = EnumStatisticsIntent
    typealias ViewState = StatisticsViewState
    
    private func initialIntent() -> Observable<Intent> {
        return Observable.just(Intent.InitialIntent)
    }
    
    func intents() -> Observable<Intent> {
        return initialIntent()
    }
    
    func render(state: ViewState) {
        if (state.isLoading) {
            statisticsLabel.text = NSLocalizedString("loading", comment: "")
        }
        
        if (state.error != nil) {
            statisticsLabel.text = NSLocalizedString("statistics_error", comment: "")
        }
        
        if (state.error == nil && !state.isLoading) {
            showStatistics(numberOfActiveTasks: state.activeCount, numberOfCompletedTasks: state.completedCount)
        }
    }
    
    private func showStatistics(numberOfActiveTasks: Int, numberOfCompletedTasks: Int) {
        if (numberOfCompletedTasks == 0 && numberOfActiveTasks == 0) {
            statisticsLabel.text = NSLocalizedString("statistics_no_tasks", comment: "")
        } else {
            var displayString = NSLocalizedString("statistics_active_tasks", comment: "")
            displayString += " "
            displayString += String.init(numberOfActiveTasks)
            displayString += "\n"
            displayString += NSLocalizedString("statistics_completed_tasks", comment: "")
            displayString += " "
            displayString += String.init(numberOfCompletedTasks)
            
            statisticsLabel.text = displayString
        }
      }
}

extension StatisticsViewController : MenuContentViewClickListener {
    
    func onClickLinstener(indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tasksViewController = storyBoard.instantiateViewController(withIdentifier: "TasksViewController") as! TasksViewController
            tasksViewController.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true, completion: nil)
            self.present(tasksViewController, animated: false, completion: nil)
        case 1:
            self.bottomDrawerViewController.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

class StatisticsViewController: BaseDrawerViewController {
    
    @IBOutlet weak var statisticsLabel: UILabel!
    
    // Used to manage the data flow lifecycle and avoid memory leak.
    lazy var disposables: CompositeDisposable = CompositeDisposable()
    
    private lazy var viewModel : StatisticsViewModel = StatisticsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindMaterialAppbar()
        bind()
        // Do any additional setup after loading the view.
    }
    
    override func bindMenuItemAction() {
        (bottomDrawerViewController.contentViewController as! MenuContentViewController).setCallbackListener(listener: self)
    }
    
    override func bindMaterialAppbar() {
        super.bindMaterialAppbar()
        
        let materailAppbarTitle = UILabel()
        materailAppbarTitle.text = NSLocalizedString("statistics_title", comment: "")
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
