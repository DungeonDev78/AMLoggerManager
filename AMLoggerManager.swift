//
//  AMLoggerManager.swift
//  AMLogger
//
//  Created with 💪 by Alessandro Manilii.
//  Copyright © 2019 Alessandro Manilii. All rights reserved.
//

import UIKit

// MARK: - AMLoggerManager
public class AMLoggerManager {


    // MARK: - AMLoggerItem
    /// Struct used to log/show all the message
    fileprivate struct AMLoggerItem {
        var message: String
        var date = Date()

        init(with log: String) {
            self.message = log
        }
    }

    // MARK: - AMLoggerPresentedState
    /// Handle the state of the ViewController
    ///
    /// - presented: is on screen
    /// - notPresented: is NOT on screen
    public enum AMLoggerPresentedState {
        case presented
        case notPresented
    }

    // MARK: - Singleton initialization
    private init() { }
    public static let shared = AMLoggerManager()

    // MARK: - Properties
    public var presentedState = AMLoggerPresentedState.notPresented
    fileprivate var datasource = [AMLoggerItem]()

    /// Gesture used to activate the UITableViewController. By default a UIScreenEdgePanGestureRecognizer is used
    fileprivate var gesture: UIGestureRecognizer = {
        let edgePan = UIScreenEdgePanGestureRecognizer()
        edgePan.edges = .right
        return edgePan
    }()

    fileprivate var title = "LOGGER"

    // MARK: - Public methods

    /// Configure the manager with a specific gesture used to show the UITableViewController
    ///
    /// - Parameter gesture: the custom gesture choosen
    public func configure(gesture: UIGestureRecognizer, title: String? = nil) {
        self.gesture = gesture
        self.title = title ?? "LOGGER"
    }

    /// Add an item to the logger
    ///
    /// - Parameter log: the stringed log needed to add
    public func add(_ log: String) {
        let item = AMLoggerItem.init(with: log)
        datasource.append(item)
    }
}


// MARK: - AMLoggerTVC
class AMLoggerController: UITableViewController {

    // MARK: - Properties
    fileprivate let datasource = AMLoggerManager.shared.datasource
    private let cellIdentifier = "AMLoggerCell"
    private let lightTransparentBlack = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3969285103)
    private let darkTransparentBlack = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5932148973)

    // MARK: - Presenting static method
    class func presentFrom(_ parentVC: UIViewController, title: String) {
        let navController = UINavigationController()
        let tvc: AMLoggerController = AMLoggerController()
        navController.pushViewController(tvc, animated: false)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve

        tvc.title = AMLoggerManager.shared.title
        parentVC.present(navController, animated: true, completion: nil)
    }

    // MARK: - UITableViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTVC()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Scrolls if needed
        if datasource.count > 0 {
            tableView.scrollToRow(at: IndexPath.init(item: datasource.count-1, section: 0),
                                  at: UITableView.ScrollPosition.bottom,
                                  animated: false)
        }
    }

    /// General configuration of the UITableViewController
    func setupTVC() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissBtnTapped))
        view.backgroundColor = lightTransparentBlack
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        AMLoggerManager.shared.presentedState = .presented
    }

    /// Dismiss the UITableViewController
    @objc func dismissBtnTapped() {
        dismiss(animated: true) {
            AMLoggerManager.shared.presentedState = .notPresented
        }
    }

    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = datasource[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(item.date)\n\n\(item.message)"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.init(name: "Menlo-Regular", size: 9.0)
        indexPath.row % 2 == 0 ? (cell.backgroundColor = darkTransparentBlack) : (cell.backgroundColor = lightTransparentBlack)
        return cell
    }

    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Share the log using the standard UIActivityViewController
        let shareAction = UITableViewRowAction(style: .default, title: "Share\nLog", handler: { [weak self] (action, indexPath) in
            var shareText = ""
            if let item = self?.datasource[indexPath.row] {
                shareText = "\(item.date)\n\n\(item.message)"
            }
            let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
            self?.present(vc, animated: true)
        })
        shareAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

        return [shareAction]
    }
}


// MARK: - UIViewController Extensions
public extension UIViewController {

    /// Enable the AMLoggerController in the colling UIViewController
    func enableLoggerController() {
        let gesture = AMLoggerManager.shared.gesture
        gesture.addTarget(self, action:  #selector(gestureDidActivateAction))
        view.addGestureRecognizer(gesture)
    }
}

private extension UIViewController {
    /// Activate the presenting action for the AMLoggerController
    ///
    /// - Parameter recognizer: the gesture that enabled the action
    @objc func gestureDidActivateAction(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .recognized && AMLoggerManager.shared.presentedState == .notPresented {
            AMLoggerController.presentFrom(self)
        }
    }
}
