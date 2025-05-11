
import Foundation
import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpMessageListener()
        setUpLongPressGestureRecognizer()
    }
    
    init(_ messageVM: MessageViewModel) {
        self.messageVM = messageVM
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        subscriptions.forEach{ $0.cancel() }
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let messageVM: MessageViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCells"
    
    private var startingFrame: CGRect?
    private var blurView: UIVisualEffectView?
    private var focusedView: UIView?
    private var highlightedCell: UICollectionViewCell?
    private var reactionHostVC: UIViewController?
    private var menuHostVC: UIViewController?
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefresh
    }()
    
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        section.interGroupSpacing = -10
        return section
    }
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()
    
    private let pullToRefreshButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = UIColor(named: "light_background")
        buttonConfig.baseForegroundColor = UIColor(named: "light_text_color")
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfig.attributedTitle = AttributedString("Tải thêm", attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setUpViews() {
        view.addSubview(messageCollectionView)
        
        NSLayoutConstraint.activate([
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func addPullToRefreshButton() {
        view.addSubview(pullToRefreshButtonView)
        
        NSLayoutConstraint.activate([
            pullToRefreshButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pullToRefreshButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setUpMessageListener() {
        let delay = 200
        messageVM.$messageList
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messageCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        messageVM.$scrollToBottom
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messageCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }.store(in: &subscriptions)
    }
    
    @objc private func refreshData() {
        messageCollectionView.refreshControl?.endRefreshing()
        messageVM.getMessages()
    }
}

extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        let message = messageVM.messageList[indexPath.item]
        let isShowDateMessage = messageVM.isShowDateMessage(for: message, at: indexPath.item)
        cell.contentConfiguration = UIHostingConfiguration {
            MessageCell(message: message, isShowDateMessage: isShowDateMessage) {
                self.messageVM.handleMessageAction(message)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageVM.messageList.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
    }
    
    private func attachReactionAndMenu(to item: MessageModel, in window: UIWindow, _ isNewDay: Bool) {
        guard let focusedView else {return}
        
        let reactionPickerView = ChatReactionPickerView(message: item){ reaction in
            if reaction != .more {
                self.messageVM.reactMessage(message: item, reaction: reaction)
            }
            self.dismissContextMenu()
        }
        
        let reactionHostVC = UIHostingController(rootView: reactionPickerView)
        reactionHostVC.view.backgroundColor = .clear
        reactionHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(reactionHostVC.view)
        
        let reactionPadding: CGFloat = isNewDay ? 45 : 5
        
        reactionHostVC.view.bottomAnchor.constraint(equalTo: focusedView.topAnchor, constant: reactionPadding).isActive = true
        reactionHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = !item.isMyMessage
        reactionHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = item.isMyMessage
        
        let menuView = MessageMenuView(message: item)
        let menuHostVC = UIHostingController(rootView: menuView)
        menuHostVC.view.backgroundColor = .clear
        menuHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(menuHostVC.view)
        menuHostVC.view.topAnchor.constraint(equalTo: focusedView.bottomAnchor, constant: 5).isActive = true
        menuHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = !item.isMyMessage
        menuHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = item.isMyMessage
        
        self.reactionHostVC = reactionHostVC
        self.menuHostVC = menuHostVC
    }
    
    @objc private func dismissContextMenu() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) { [weak self] in
            guard let self = self else {return}
            focusedView?.transform = .identity
            focusedView?.frame = startingFrame ?? .zero
            reactionHostVC?.view.removeFromSuperview()
            menuHostVC?.view.removeFromSuperview()
            blurView?.alpha = 0
        } completion: { [weak self] _ in
            self?.highlightedCell?.alpha = 1
            self?.blurView?.removeFromSuperview()
            self?.focusedView?.removeFromSuperview()
            
            self?.highlightedCell = nil
            self?.blurView = nil
            self?.focusedView = nil
            self?.reactionHostVC = nil
            self?.menuHostVC = nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            if messageVM.isPaginatable {
                addPullToRefreshButton()
                pullToRefreshButtonView.alpha = 1
            } else {
                pullToRefreshButtonView.alpha = 0
            }
        } else {
            pullToRefreshButtonView.alpha = 0
        }
    }
}

extension CALayer {
    func applyShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = .init(width: x, height: y)
        shadowRadius = blur
        masksToBounds = false
    }
}

extension MessageListController {
    private func setUpLongPressGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        
        longPressGesture.minimumPressDuration = 0.5
        messageCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showContextMenu(_ gesture: UILongPressGestureRecognizer){
        guard gesture.state == .began else {return}
        let point = gesture.location(in: messageCollectionView)
        guard let indexPath = messageCollectionView.indexPathForItem(at: point) else {return}
        guard let selectedCell = messageCollectionView.cellForItem(at: indexPath) else {return}
        startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContextMenu))
        
        focusedView = UIView(frame: startingFrame ?? .zero)
        guard let focusedView else {return}
        guard let keyWindow = UIWindowScene.current?.keyWindow else {return}
        guard let snapshotView = selectedCell.snapshotView(afterScreenUpdates: false) else {return}
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView else {return}
        blurView.alpha = 0
        blurView.contentView.addGestureRecognizer(tapGesture)
        blurView.contentView.isUserInteractionEnabled = true
        highlightedCell = selectedCell
        highlightedCell?.alpha = 0
        
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusedView)
        focusedView.addSubview(snapshotView)
        
        let message = messageVM.messageList[indexPath.item]
        let isNewDay = messageVM.isShowDateMessage(for: message, at: indexPath.item)
        attachReactionAndMenu(to: message, in: keyWindow, isNewDay)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
            blurView.alpha = 1
            blurView.frame = keyWindow.frame
            focusedView.center.y = keyWindow.center.y
            snapshotView.frame = focusedView.bounds
            
            snapshotView.layer.applyShadow(color: UIColor.gray, alpha: 0.2, x: 0, y: 2, blur: 4)
        }
    }
}

private extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool){
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else {return}
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

#Preview{
    MessageListView(MessageViewModel(contact: ContactModel(dict: [:])))
}



