//
//  MailTableViewController.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit
import SwipeCellKit

class MailTableViewController: UITableViewController {
    var emails: [Email] = []
    
    var defaultOptions = SwipeOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var usesTallCells = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        view.layoutMargins.left = 32
        
        resetData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell") as! MailCell
        cell.delegate = self
        cell.selectedBackgroundView = createSelectedBackgroundView()
        
        let email = emails[indexPath.row]
        cell.fromLabel.text = email.from
        cell.dateLabel.text = email.relativeDateString
        cell.subjectLabel.text = email.subject
        cell.bodyLabel.text = email.body
        cell.bodyLabel.numberOfLines = usesTallCells ? 0 : 2
        cell.unread = email.unread
        
        return cell
    }
    
    func visibleRect(for tableView: UITableView) -> CGRect? {
        if usesTallCells == false { return nil }
        
        if #available(iOS 11.0, *) {
            return tableView.safeAreaLayoutGuide.layoutFrame
        } else {
            let topInset = navigationController?.navigationBar.frame.height ?? 0
            let bottomInset = navigationController?.toolbar?.frame.height ?? 0
            let bounds = tableView.bounds
            
            return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func moreTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Swipe Transition Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Border", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .border }))
        controller.addAction(UIAlertAction(title: "Drag", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .drag }))
        controller.addAction(UIAlertAction(title: "Reveal", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .reveal }))
        controller.addAction(UIAlertAction(title: "\(isSwipeRightEnabled ? "Disable" : "Enable") Swipe Right", style: .default, handler: { _ in self.isSwipeRightEnabled = !self.isSwipeRightEnabled }))
        controller.addAction(UIAlertAction(title: "Button Display Mode", style: .default, handler: { _ in self.buttonDisplayModeTapped() }))
        controller.addAction(UIAlertAction(title: "Button Style", style: .default, handler: { _ in self.buttonStyleTapped() }))
        controller.addAction(UIAlertAction(title: "Cell Height", style: .default, handler: { _ in self.cellHeightTapped() }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in self.resetData() }))
        present(controller, animated: true, completion: nil)
    }
    
    func buttonDisplayModeTapped() {
        let controller = UIAlertController(title: "Button Display Mode", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Image + Title", style: .default, handler: { _ in self.buttonDisplayMode = .titleAndImage }))
        controller.addAction(UIAlertAction(title: "Image Only", style: .default, handler: { _ in self.buttonDisplayMode = .imageOnly }))
        controller.addAction(UIAlertAction(title: "Title Only", style: .default, handler: { _ in self.buttonDisplayMode = .titleOnly }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func buttonStyleTapped() {
        let controller = UIAlertController(title: "Button Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Background Color", style: .default, handler: { _ in
            self.buttonStyle = .backgroundColor
            self.defaultOptions.transitionStyle = .border
        }))
        controller.addAction(UIAlertAction(title: "Circular", style: .default, handler: { _ in
            self.buttonStyle = .circular
            self.defaultOptions.transitionStyle = .reveal
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func cellHeightTapped() {
        let controller = UIAlertController(title: "Cell Height", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Normal", style: .default, handler: { _ in
            self.usesTallCells = false
            self.tableView.reloadData()
        }))
        controller.addAction(UIAlertAction(title: "Tall", style: .default, handler: { _ in
            self.usesTallCells = true
            self.tableView.reloadData()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
    
    func resetData() {
        emails = mockEmails
        emails.forEach { $0.unread = false }
        usesTallCells = false
        tableView.reloadData()
    }
}

extension MailTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let email = emails[indexPath.row]
        
        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
                let updatedStatus = !email.unread
                email.unread = updatedStatus
                
                let cell = tableView.cellForRow(at: indexPath) as! MailCell
                cell.setUnread(updatedStatus, animated: true)
            }
            
            read.hidesWhenSelected = true
            read.accessibilityLabel = email.unread ? "Mark as Read" : "Mark as Unread"
            
            let descriptor: ActionDescriptor = email.unread ? .read : .unread
            configure(action: read, with: descriptor)
            
            return [read]
        } else {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.emails.remove(at: indexPath.row)
            }
            configure(action: delete, with: .trash)
            
            let cell = tableView.cellForRow(at: indexPath) as! MailCell
            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
                self.present(controller, animated: true, completion: nil)
            }
            configure(action: more, with: .more)
            
            return [delete, flag, more]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}

class MailCell: SwipeTableViewCell {
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var subjectLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    var animator: Any?
    
    var indicatorView = IndicatorView(frame: .zero)
    
    var unread = false {
        didSet {
            indicatorView.transform = unread ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        }
    }
    
    override func awakeFromNib() {
        setupIndicatorView()
    }
    
    func setupIndicatorView() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = tintColor
        indicatorView.backgroundColor = .clear
        contentView.addSubview(indicatorView)
        
        let size: CGFloat = 12
        indicatorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: fromLabel.leftAnchor, constant: -16).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor).isActive = true
    }
    
    func setUnread(_ unread: Bool, animated: Bool) {
        let closure = {
            self.unread = unread
        }
        
        if #available(iOS 10, *), animated {
            var localAnimator = self.animator as? UIViewPropertyAnimator
            localAnimator?.stopAnimation(true)
            
            localAnimator = unread ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.4) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0)
            localAnimator?.addAnimations(closure)
            localAnimator?.startAnimation()
            
            self.animator = localAnimator
        } else {
            closure()
        }
    }
}
