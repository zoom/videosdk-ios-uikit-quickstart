//
//  SessionViewController.swift
//  MyVideoSDKApp
//
//

import UIKit
// (0)
import ZoomVideoSDK

enum ControlOption: Int {
    case toggleVideo = 0, toggleAudio, shareScreen, endSession
}

class SessionViewController: UIViewController {
    
    var loadingLabel: UILabel!
    
    var remoteView: UIView!
    var localView: UIView!
    var remotePlaceholderLabel: UILabel!
    var remotePlaceholderView: UIView!
    var localPlaceholderView: UIView!
    
    var sharedView: UIView!
    
    var tabBar: UITabBar!
    var toggleVideoBarItem: UITabBarItem!
    var toggleAudioBarItem: UITabBarItem!
    var toggleShareBarItem: UITabBarItem!
    
    // MARK: Session Information
    // TODO: Ensure that you do not hard code JWT or any other confidential credentials in your production app.
    // details: https://developers.zoom.us/docs/video-sdk/ios/sessions/#create-and-join-a-session
    // (2)
    let token = ""            // JWT
    let sessionName = ""      // NOTE: Must match "tpc" field in JWT
    let userName = ""
    let sessionPassword = ""  // optional
    
    // MARK: UI setup
    
    override func loadView() {
        super.loadView()
        
        loadingLabel = UILabel(frame: .zero)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingLabel)
        
        remoteView = UIView(frame: .zero)
        remoteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(remoteView)
        
        localView = UIView(frame: .zero)
        localView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(localView)
        
        remotePlaceholderView = UIView(frame: .zero)
        remotePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(remotePlaceholderView)
        
        sharedView = UIView(frame: .zero)
        sharedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sharedView)
        
        localPlaceholderView = UIView(frame: .zero)
        localPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(localPlaceholderView)
        
        tabBar = UITabBar(frame: .zero)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
        
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            
            remoteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            remoteView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            remoteView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            remotePlaceholderView.centerXAnchor.constraint(equalTo: remoteView.centerXAnchor),
            remotePlaceholderView.centerYAnchor.constraint(equalTo: remoteView.centerYAnchor),
            remotePlaceholderView.heightAnchor.constraint(equalToConstant: 120),
            
            localView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            localView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            localView.widthAnchor.constraint(equalToConstant: 120),
            localView.heightAnchor.constraint(equalToConstant: 180),
            
            sharedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sharedView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            sharedView.widthAnchor.constraint(equalToConstant: 120),
            sharedView.heightAnchor.constraint(equalToConstant: 180),
            
            localPlaceholderView.centerXAnchor.constraint(equalTo: localView.centerXAnchor),
            localPlaceholderView.centerYAnchor.constraint(equalTo: localView.centerYAnchor),
            localPlaceholderView.heightAnchor.constraint(equalToConstant: 50),
            
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabBar.topAnchor.constraint(equalTo: remoteView.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        // (3)
        ZoomVideoSDK.shareInstance()?.delegate = self
        loadingLabel.textColor = .white
        loadingLabel.text = "Loading Session..."
        
        tabBar.delegate = self
        toggleVideoBarItem = UITabBarItem(title: "Stop Video", image: UIImage(systemName: "video.slash"), tag: ControlOption.toggleVideo.rawValue)
        toggleAudioBarItem = UITabBarItem(title: "Mute", image: UIImage(systemName: "mic.slash"), tag: ControlOption.toggleAudio.rawValue)
        toggleShareBarItem = UITabBarItem(title: "Share Screen", image: UIImage(systemName: "rectangle.on.rectangle"), tag: ControlOption.shareScreen.rawValue)
        let endSessionBarItem = UITabBarItem(title: "End Session", image: UIImage(systemName: "phone.down"), tag: ControlOption.endSession.rawValue)
        tabBar.items = [toggleVideoBarItem, toggleAudioBarItem, toggleShareBarItem, endSessionBarItem]
        tabBar.isHidden = true
        
        let remotePlaceholderImageView = UIImageView(image: UIImage(systemName: "person.fill"))
        remotePlaceholderImageView.translatesAutoresizingMaskIntoConstraints = false
        remotePlaceholderImageView.contentMode = .scaleAspectFill
        remotePlaceholderLabel = UILabel(frame: .zero)
        remotePlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        remotePlaceholderLabel.textColor = .white
        remotePlaceholderView.addSubview(remotePlaceholderImageView)
        remotePlaceholderView.addSubview(remotePlaceholderLabel)
        remotePlaceholderView.isHidden = true
        
        let localPlaceholderImageView = UIImageView(image: UIImage(systemName: "person.fill"))
        localPlaceholderImageView.translatesAutoresizingMaskIntoConstraints = false
        localPlaceholderImageView.contentMode = .scaleAspectFill
        let localPlaceholderLabel = UILabel(frame: .zero)
        localPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        localPlaceholderLabel.textColor = .white
        localPlaceholderLabel.text = userName
        localPlaceholderView.addSubview(localPlaceholderImageView)
        localPlaceholderView.addSubview(localPlaceholderLabel)
        localPlaceholderView.isHidden = true
        
        localView.isHidden = true
        
        let sharedViewLabel = UILabel(frame: .zero)
        sharedViewLabel.translatesAutoresizingMaskIntoConstraints = false
        sharedViewLabel.numberOfLines = 0
        sharedViewLabel.textAlignment = .center
        sharedViewLabel.textColor = .white
        sharedViewLabel.text = "Now Sharing This View!"
        sharedView.backgroundColor = .blue
        sharedView.addSubview(sharedViewLabel)
        sharedView.isHidden = true
        
        NSLayoutConstraint.activate([
            remotePlaceholderImageView.leadingAnchor.constraint(equalTo: remotePlaceholderView.leadingAnchor),
            remotePlaceholderImageView.trailingAnchor.constraint(equalTo: remotePlaceholderView.trailingAnchor),
            remotePlaceholderImageView.centerYAnchor.constraint(equalTo: remotePlaceholderView.centerYAnchor),
            
            remotePlaceholderLabel.leadingAnchor.constraint(equalTo: remotePlaceholderView.leadingAnchor),
            remotePlaceholderLabel.trailingAnchor.constraint(equalTo: remotePlaceholderView.trailingAnchor),
            remotePlaceholderLabel.topAnchor.constraint(equalTo: remotePlaceholderImageView.bottomAnchor),
            remotePlaceholderLabel.bottomAnchor.constraint(equalTo: remotePlaceholderView.bottomAnchor),
            
            localPlaceholderImageView.leadingAnchor.constraint(equalTo: localPlaceholderView.leadingAnchor),
            localPlaceholderImageView.trailingAnchor.constraint(equalTo: localPlaceholderView.trailingAnchor),
            localPlaceholderImageView.centerYAnchor.constraint(equalTo: localPlaceholderView.centerYAnchor),
            
            localPlaceholderLabel.leadingAnchor.constraint(equalTo: localPlaceholderView.leadingAnchor),
            localPlaceholderLabel.trailingAnchor.constraint(equalTo: localPlaceholderView.trailingAnchor),
            localPlaceholderLabel.topAnchor.constraint(equalTo: localPlaceholderImageView.bottomAnchor),
            localPlaceholderLabel.bottomAnchor.constraint(equalTo: localPlaceholderView.bottomAnchor),
            
            sharedViewLabel.leadingAnchor.constraint(equalTo: sharedView.leadingAnchor),
            sharedViewLabel.trailingAnchor.constraint(equalTo: sharedView.trailingAnchor),
            sharedViewLabel.centerYAnchor.constraint(equalTo: sharedView.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // (2)
        // TODO: Ensure that you do not hard code JWT or any other confidential credentials in your production app.
        let sessionContext = ZoomVideoSDKSessionContext()
        sessionContext.token = token
        sessionContext.sessionName = sessionName
        sessionContext.userName = userName
        // sessionContext.sessionPassword = sessionPassword
        
        // Join Session
        if (ZoomVideoSDK.shareInstance()?.joinSession(sessionContext)) != nil {
            // Session joined successfully.
            print("Session joined")
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "Join session failed", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
        }
    }
}
    
// MARK: ZoomVideoSDKDelegate
// (3)
extension SessionViewController: ZoomVideoSDKDelegate {
    
    func onSessionJoin() {
        // (4)
        localPlaceholderView.isHidden = false

        // Render the current user's video
        if let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf(),
           // Get local user's video canvas
           let myUserVideoCanvas = myUser.getVideoCanvas() {
            // Turning on video for first time
            if let myVideoIsOn = myUserVideoCanvas.videoStatus()?.on {
                if myVideoIsOn == false {
                    // Ensure this is called on main thread
                    Task(priority: .background) {
                        // Update UI
                        self.loadingLabel.isHidden = true
                        self.tabBar.isHidden = false

                        // Subscribe to video canvas, render to local user view
                        self.localPlaceholderView.isHidden = true
                        self.localView.isHidden = false
                        myUserVideoCanvas.subscribe(with: self.localView, aspectMode: .panAndScan, andResolution: ._Auto)
                    }
                }
            }
        }
    }
    
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        // (8)
        // Get remote user
        if let userArray = users, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    remotePlaceholderLabel.text = user.getName()
                    remotePlaceholderView.isHidden = false
                    if let remoteUserVideoCanvas = user.getVideoCanvas() {
                        Task(priority: .background) {
                            // Subscribe to video canvas, render to remote user view
                            remotePlaceholderView.isHidden = true
                            remoteUserVideoCanvas.subscribe(with: self.remoteView, aspectMode: .panAndScan, andResolution: ._Auto)
                        }
                    }
                    return
                }
            }
        }
    }
    
    func onUserVideoStatusChanged(_ helper: ZoomVideoSDKVideoHelper?, user: [ZoomVideoSDKUser]?) {
        // (9)
        // Get remote user
        if let userArray = user, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    // Get remote user canvas
                    if let remoteUserVideoCanvas = user.getVideoCanvas() {
                        // Check remote user's video status
                        if let remoteUserVideoIsOn = remoteUserVideoCanvas.videoStatus()?.on,
                           remoteUserVideoIsOn == true {
                            Task(priority: .background) {
                                remotePlaceholderView.isHidden = true
                            }
                        } else {
                            Task(priority: .background) {
                                // Update UI
                                remotePlaceholderView.isHidden = false
                            }
                        }
                    }
                }
                return
            }
        }
    }
    
    func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, shareAction: ZoomVideoSDKShareAction?) {
        // (10)
        // Display the other user's share view only, not our own
        if let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            guard user?.getID() != myself.getID() else {
                return
            }
        }
        
        // Get share canvas of share action.
        if let shareCanvas = shareAction?.getShareCanvas() {
            // Ensure that sharing has been started.
            if let status = shareAction?.getShareStatus()  {
                if status == ZoomVideoSDKReceiveSharingStatus.start {
                    // Set video aspect.
                    let videoAspect = ZoomVideoSDKVideoAspect.panAndScan

                    // Set video resolution.
                    let videoResolution = ZoomVideoSDKVideoResolution._Auto
                    Task(priority: .background) {
                        // Unsubscribe to the user's video stream.
                        user?.getVideoCanvas()?.unSubscribe(with: self.remoteView)
                        remotePlaceholderView.isHidden = true

                        // Subscribe to the user's share stream.
                        let error = shareCanvas.subscribe(with: self.remoteView, aspectMode: videoAspect, andResolution: videoResolution)
                        print("Share error: \(error.rawValue)")

                        // Disable sharing for local user
                        self.toggleShareBarItem.isEnabled = false
                        toggleShareBarItem.title = "Sharing Disabled"
                    }
                } else if status == ZoomVideoSDKReceiveSharingStatus.stop {
                    shareCanvas.unSubscribe(with: remoteView)
                    // Re-subscribe to the user's video stream
                    user?.getVideoCanvas()?.subscribe(with: self.remoteView, aspectMode: ZoomVideoSDKVideoAspect.panAndScan, andResolution: ZoomVideoSDKVideoResolution._Auto)
                    // Re-enable sharing for local user
                    self.toggleShareBarItem.isEnabled = true
                    toggleShareBarItem.title = "Screen Share"
                    
                }
            }
        }
    }
    
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        // (11)
        // Get remote user
        if let userArray = users, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    // Unsubscribe to remote user's video
                    if let remoteUserVideoCanvas = user.getVideoCanvas() {
                        Task(priority: .background) {
                            remoteUserVideoCanvas.unSubscribe(with: self.remoteView)
                        }
                    }
                    // Unsubscribe to remote user's screen share
                    if let remoteUserShareCanvas = getStartShareAction(user)?.getShareCanvas() {
                        Task(priority: .background) {
                            remoteUserShareCanvas.unSubscribe(with: self.remoteView)
                        }
                    }
                    return
                }
            }
        }
    }
    
    func onSessionLeave() {
        // (14)
        let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()
        // Unsubscribe local user's video canvas.
        if let usersVideoCanvas = myUser?.getVideoCanvas() {
            // Unsubscribe user's video canvas to stop rendering their video stream.
            Task(priority: .background) {
                usersVideoCanvas.unSubscribe(with: localView)
            }
        }
        
        // Get remote user
        if let remoteUsers = ZoomVideoSDK.shareInstance()?.getSession()?.getRemoteUsers() {
            for user in remoteUsers {
                // Unsubscribe remote user's video canvas.
                if let remoteUserVideoCanvas = user.getVideoCanvas() {
                    Task(priority: .background) {
                        remoteUserVideoCanvas.unSubscribe(with: self.remoteView)
                    }
                }
                // Unsubscribe remote user's screen share canvas.
                if let remoteUserShareCanvas = getStartShareAction(user)?.getShareCanvas() {
                    Task(priority: .background) {
                        remoteUserShareCanvas.unSubscribe(with: self.remoteView)
                    }
                }
                
            }
        }
        
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: Convenience method
    private func getStartShareAction(_ user: ZoomVideoSDKUser) -> ZoomVideoSDKShareAction? {
        // (12)
        guard let shareActionList = user.getShareActionList() else {
            return nil
        }

        // get the specific share action that has .start status (screen sharing in progress)
        return shareActionList.filter { $0.getShareStatus() == ZoomVideoSDKReceiveSharingStatus.start }.first
    }
}

// MARK: UITabBarDelegate
extension SessionViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.selectedItem = nil
        
        switch item.tag {
        case ControlOption.toggleVideo.rawValue:
            tabBar.items![ControlOption.toggleVideo.rawValue].isEnabled = false
            
            // (5)
            if let usersVideoCanvas = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getVideoCanvas(),
               // Get ZoomVideoSDKVideoHelper to control video
               let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper() {
                
                if let myVideoIsOn = usersVideoCanvas.videoStatus()?.on,
                   myVideoIsOn == true {
                    Task(priority: .background) {
                        let error = videoHelper.stopVideo()
                        print("Stop error: \(error.rawValue)")
                        
                        // Update UI
                        toggleVideoBarItem.title = "Start Video"
                        toggleVideoBarItem.image = UIImage(systemName: "video")
                        localPlaceholderView.isHidden = false
                    }
                } else {
                    Task(priority: .background) {
                        let error = videoHelper.startVideo()
                        print("Start error: \(error.rawValue)")
                        
                        // Update UI
                        self.toggleVideoBarItem.title = "Stop Video"
                        toggleVideoBarItem.image = UIImage(systemName: "video.slash")
                        localPlaceholderView.isHidden = true
                    }
                }
            }
            
            tabBar.items![ControlOption.toggleVideo.rawValue].isEnabled = true
            return
            
        case ControlOption.toggleAudio.rawValue:
            tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = false
            
            // (6)
            let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()
            // Get the user's audio status
            if let audioStatus = myUser?.audioStatus(),
               // Get ZoomVideoSDKAudioHelper to control audio
               let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() {
                
                // Check if the user's audio type is none
                if audioStatus.audioType == .none {
                    audioHelper.startAudio()
                } else {
                    // Toggle audio based on mute status
                    if audioStatus.isMuted {
                        let error = audioHelper.unmuteAudio(myUser)
                        print("Unmute error: \(error.rawValue)")
                        toggleAudioBarItem.title = "Mute"
                        toggleAudioBarItem.image = UIImage(systemName: "mic.slash")
                    } else {
                        let error = audioHelper.muteAudio(myUser)
                        print("Mute error: \(error.rawValue)")
                        toggleAudioBarItem.title = "Start Audio"
                        toggleAudioBarItem.image = UIImage(systemName: "mic")
                    }
                }
            }
            
            tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = true
            return
            
        case ControlOption.shareScreen.rawValue:
            tabBar.items![ControlOption.shareScreen.rawValue].isEnabled = false
            
            // (7)
            // Get the ZoomVideoSDKShareHelper to perform UIView sharing actions.
            if let shareHelper = ZoomVideoSDK.shareInstance()?.getShareHelper() {
                // get sharing status
                let myUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()
                guard let shareStatus = myUser?.getShareActionList()?.first?.getShareStatus() else {
                    // No prior sharing status, so local user now starts sharing
                    Task(priority: .background) {
                        sharedView.isHidden = false
                        let startResult = shareHelper.startShare(with: sharedView)
                        if startResult == .Errors_Success {
                            // View is now being shared. UI controls switch for stop sharing.
                            toggleShareBarItem.image = UIImage(systemName: "rectangle.on.rectangle.slash")
                            toggleShareBarItem.title = "Stop Sharing"
                        } else {
                            // The view could not be shared.
                            print("Sharing failed")
                        }
                    }
                    
                    tabBar.items![ControlOption.shareScreen.rawValue].isEnabled = true
                    return
                }
                
                switch (shareStatus) {
                case .none:
                    return
                case .start:
                    // Local user has already been sharing, so stop
                    Task(priority: .background) {
                        let stopResult = shareHelper.stopShare()
                        if stopResult == .Errors_Success {
                            // View is no longer being shared. UI controls switch for start sharing.
                            toggleShareBarItem.image = UIImage(systemName: "rectangle.on.rectangle")
                            toggleShareBarItem.title = "Share Screen"
                            sharedView.isHidden = true
                        } else {
                            print("Stop Sharing failed")
                        }
                    }
                case .pause:
                    return
                case .resume:
                    return
                case .stop:
                    // Local user re-starts screen sharing
                    Task(priority: .background) {
                        sharedView.isHidden = false
                        let startResult = shareHelper.startShare(with: sharedView)
                        if startResult == .Errors_Success {
                            // View is now being shared. UI controls switch for stop sharing.
                            toggleShareBarItem.image = UIImage(systemName: "rectangle.on.rectangle.slash")
                            toggleShareBarItem.title = "Stop Sharing"
                        } else {
                            // The view could not be shared.
                            print("Sharing failed")
                        }
                    }
                @unknown default:
                    return
                }
            }
            
            tabBar.items![ControlOption.shareScreen.rawValue].isEnabled = true
            return
            
        case ControlOption.endSession.rawValue:
            tabBar.isUserInteractionEnabled = false
            
            // (13)
            // Stop screen sharing if in progress
            if let shareHelper = ZoomVideoSDK.shareInstance()?.getShareHelper() {
                let stopResult = shareHelper.stopShare()
                if stopResult == .Errors_Success {
                    print("Stop sharing succeeded")
                } else {
                    print("Stop sharing failed")
                }
            }
            
            ZoomVideoSDK.shareInstance()?.leaveSession(true)

            return
            
        default:
            return
        }
    }
}
