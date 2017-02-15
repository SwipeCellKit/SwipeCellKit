//
//  MailViewController.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit
import SwipeCellKit

class MailViewController: UITableViewController {
    var emails: [Email] = []
    var defaultOptions = SwipeTableOptions()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
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
        cell.unread = email.unread
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func moreTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Swipe Transition Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Border", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .border }))
        controller.addAction(UIAlertAction(title: "Drag", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .drag }))
        controller.addAction(UIAlertAction(title: "Reveal", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .reveal }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in self.resetData() }))
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
        tableView.reloadData()
    }
}

extension MailViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction] {
        let email = emails[indexPath.row]

        if orientation == .left {
            let read = SwipeAction(style: .default, title: email.unread ? "Read" : "Unread") { action, indexPath in
                let updatedStatus = !email.unread
                email.unread = updatedStatus

                let cell = tableView.cellForRow(at: indexPath) as! MailCell
                cell.setUnread(updatedStatus, animated: true)
            }
            read.backgroundColor = view.tintColor
            read.image = email.unread ? #imageLiteral(resourceName: "Read") : #imageLiteral(resourceName: "Unread")
            read.hidesWhenSelected = true
            return [read]
        } else {
            let flag = SwipeAction(style: .default, title: "Flag", handler: nil)
            flag.backgroundColor = #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
            flag.hidesWhenSelected = true
            flag.image = #imageLiteral(resourceName: "Flag")
            
            let delete = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.emails.remove(at: indexPath.row)
            }
            delete.image = #imageLiteral(resourceName: "Trash")
            
            let more = SwipeAction(style: .default, title: "More") { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
            more.image = #imageLiteral(resourceName: "More")

            return [delete, flag, more]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        return options
    }
}

class MailCell: SwipeTableViewCell {
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var subjectLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
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
        indicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor).isActive = true
    }
    
    func setUnread(_ unread: Bool, animated: Bool) {
        let closure = {
            self.unread = unread
        }
        
        if animated {
            let animator = unread ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.4) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0)
            animator.addAnimations(closure)
            animator.startAnimation()
        } else {
            closure()
        }
    }
}

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}
