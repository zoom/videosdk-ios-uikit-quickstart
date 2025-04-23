import UIKit
import ZoomVideoSDK

enum ControlOption: Int {
    case toggleVideo, toggleAudio, leaveSession
}

class SessionViewController: UIViewController {
    // MARK: - Properties
    private let token = ""
    private let sessionName = "test"
    private let userName = "ios"
    
    private var loadingLabel: UILabel = UILabel()
    private var scrollView: UIScrollView = UIScrollView()
    private var videoStackView: UIStackView = UIStackView()
    private var remoteUserViews: [Int: (view: UIView, placeholder: UIView)] = [:]
    private var localView: UIView = UIView()
    private var localPlaceholder: UIView?
    private var tabBar: UITabBar = UITabBar()
    private var toggleVideoBarItem: UITabBarItem = UITabBarItem(title: "Stop Video", image: UIImage(systemName: "video.slash"), tag: ControlOption.toggleVideo.rawValue)
    private var toggleAudioBarItem: UITabBarItem = UITabBarItem(title: "Mute", image: UIImage(systemName: "mic.slash"), tag: ControlOption.toggleAudio.rawValue)
    
    private let videoViewAspectRatio: CGFloat = 1.0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ZoomVideoSDK.shareInstance()?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        joinSession()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        setupViews()
        setupConstraints()
        setupTabBar()
    }
    
    private func setupViews() {
        // Setup scroll view
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Setup video stack view
        videoStackView.axis = .vertical
        videoStackView.spacing = 8
        videoStackView.alignment = .fill
        videoStackView.distribution = .fillEqually
        
        [loadingLabel, scrollView, tabBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        scrollView.addSubview(videoStackView)
        videoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingLabel.text = "Loading Session..."
        loadingLabel.textColor = .white
    }
    
    private func setupConstraints() {
        // Main container constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            videoStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            videoStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            videoStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            videoStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            videoStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16),
            
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Loading label
        loadingLabel.center(in: view, yOffset: -30)
    }
    
    private func createPlaceholderView(with name: String) -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .darkGray
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = name
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        placeholderView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            
            stackView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
        ])
        
        return placeholderView
    }
    
    private func addLocalViewToGrid() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .black
        
        localView.translatesAutoresizingMaskIntoConstraints = false
        let placeholder = createPlaceholderView(with: userName)
        localPlaceholder = placeholder
        
        containerView.addSubview(localView)
        containerView.addSubview(placeholder)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.0/videoViewAspectRatio),
            
            localView.topAnchor.constraint(equalTo: containerView.topAnchor),
            localView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            localView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            localView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            placeholder.topAnchor.constraint(equalTo: containerView.topAnchor),
            placeholder.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            placeholder.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            placeholder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        videoStackView.addArrangedSubview(containerView)
    }
    
    private func addRemoteUserView(for user: ZoomVideoSDKUser) -> (view: UIView, placeholder: UIView) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .black
        
        let userView = UIView()
        let placeholderView = createPlaceholderView(with: user.getName() ?? "")
        
        userView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(userView)
        containerView.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.0/videoViewAspectRatio),
            
            userView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            placeholderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        videoStackView.addArrangedSubview(containerView)
        
        return (userView, placeholderView)
    }
    
    private func setupTabBar() {
        tabBar.delegate = self
        tabBar.isHidden = true
        
        let leaveSessionBarItem = UITabBarItem(title: "Leave Session", image: UIImage(systemName: "phone.down"), tag: ControlOption.leaveSession.rawValue)
        tabBar.items = [toggleVideoBarItem, toggleAudioBarItem, leaveSessionBarItem]
    }
    
    private func joinSession() {
        let sessionContext = ZoomVideoSDKSessionContext()
        sessionContext.token = token
        sessionContext.sessionName = sessionName
        sessionContext.userName = userName
        
        if ZoomVideoSDK.shareInstance()?.joinSession(sessionContext) == nil {
            let alert = UIAlertController(title: "Error", message: "Join session failed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - ZoomVideoSDKDelegate
extension SessionViewController: ZoomVideoSDKDelegate {
    func onSessionJoin() {
        guard let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(),
              let myUserVideoCanvas = myUser.getVideoCanvas() else { return }
        
        Task(priority: .background) {
            addLocalViewToGrid()
            self.loadingLabel.isHidden = true
            self.tabBar.isHidden = false
            
            // Ensure video is started
            if let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper(),
               !(myUserVideoCanvas.videoStatus()?.on ?? false) {
                _ = videoHelper.startVideo()
            }
            
            myUserVideoCanvas.subscribe(with: self.localView, aspectMode: .panAndScan, andResolution: ._Auto)
            
            // Update UI to reflect video state
            self.localPlaceholder?.isHidden = true
            self.toggleVideoBarItem.title = "Stop Video"
            self.toggleVideoBarItem.image = UIImage(systemName: "video.slash")
        }
    }
    
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        guard let users = users,
              let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return }
        
        for user in users where user.getID() != myself.getID() {
            let views = addRemoteUserView(for: user)
            remoteUserViews[user.getID()] = views
            
            if let remoteUserVideoCanvas = user.getVideoCanvas() {
                Task(priority: .background) {
                    views.placeholder.isHidden = true
                    remoteUserVideoCanvas.subscribe(with: views.view, aspectMode: .panAndScan, andResolution: ._Auto)
                }
            }
        }
    }
    
    func onUserVideoStatusChanged(_ helper: ZoomVideoSDKVideoHelper?, user: [ZoomVideoSDKUser]?) {
        guard let users = user,
              let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return }
        
        for user in users where user.getID() != myself.getID() {
            if let canvas = user.getVideoCanvas(),
               let isVideoOn = canvas.videoStatus()?.on,
               let views = remoteUserViews[user.getID()] {
                Task(priority: .background) {
                    views.placeholder.isHidden = isVideoOn
                }
            }
        }
    }
    
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        guard let users = users,
              let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return }
        
        for user in users where user.getID() != myself.getID() {
            if let canvas = user.getVideoCanvas(),
               let views = remoteUserViews[user.getID()] {
                Task(priority: .background) {
                    canvas.unSubscribe(with: views.view)
                    if let container = views.view.superview {
                        container.removeFromSuperview()
                    }
                }
                remoteUserViews.removeValue(forKey: user.getID())
            }
        }
    }
    
    func onSessionLeave() {
        if let myCanvas = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getVideoCanvas() {
            Task(priority: .background) {
                myCanvas.unSubscribe(with: self.localView)
            }
        }
        
        ZoomVideoSDK.shareInstance()?.getSession()?.getRemoteUsers()?.forEach { user in
            if let canvas = user.getVideoCanvas() {
                Task(priority: .background) {
                    canvas.unSubscribe(with: self.videoStackView)
                }
            }
        }
        
        presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - UITabBarDelegate
extension SessionViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.selectedItem = nil
        
        switch item.tag {
        case ControlOption.toggleVideo.rawValue:
            handleVideoToggle(tabBar)
        case ControlOption.toggleAudio.rawValue:
            handleAudioToggle(tabBar)
        case ControlOption.leaveSession.rawValue:
            tabBar.isUserInteractionEnabled = false
            ZoomVideoSDK.shareInstance()?.leaveSession(false)
        default:
            break
        }
    }
    
    private func handleVideoToggle(_ tabBar: UITabBar) {
        tabBar.items![ControlOption.toggleVideo.rawValue].isEnabled = false
        
        guard let canvas = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getVideoCanvas(),
              let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper(),
              let isVideoOn = canvas.videoStatus()?.on else { return }
        
        Task(priority: .background) {
            let error = isVideoOn ? videoHelper.stopVideo() : videoHelper.startVideo()
            print("\(isVideoOn ? "Stop" : "Start") error: \(error.rawValue)")
            
            // Update UI to reflect new video state
            let newVideoState = !isVideoOn
            self.toggleVideoBarItem.title = newVideoState ? "Stop Video" : "Start Video"
            self.toggleVideoBarItem.image = UIImage(systemName: newVideoState ? "video.slash" : "video")
            self.localPlaceholder?.isHidden = newVideoState
        }
        
        tabBar.items![ControlOption.toggleVideo.rawValue].isEnabled = true
    }
    
    private func handleAudioToggle(_ tabBar: UITabBar) {
        tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = false
        
        guard let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(),
              let audioStatus = myUser.audioStatus(),
              let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        
        if audioStatus.audioType == .none {
            audioHelper.startAudio()
        } else {
            let error = audioStatus.isMuted ? audioHelper.unmuteAudio(myUser) : audioHelper.muteAudio(myUser)
            print("\(audioStatus.isMuted ? "Unmute" : "Mute") error: \(error.rawValue)")
            toggleAudioBarItem.title = audioStatus.isMuted ? "Mute" : "Start Audio"
            toggleAudioBarItem.image = UIImage(systemName: audioStatus.isMuted ? "mic.slash" : "mic")
        }
        
        tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = true
    }
}

// Helper extensions
extension UIView {
    func center(in view: UIView, yOffset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yOffset).isActive = true
    }
    
    func pinToSafeArea(of view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
               trailing: NSLayoutXAxisAnchor? = nil,
               padding: UIEdgeInsets = .zero,
               size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
}
