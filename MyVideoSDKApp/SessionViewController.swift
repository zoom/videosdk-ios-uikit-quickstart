//
//  SessionViewController.swift
//  MyVideoSDKApp
//
//

import UIKit
// (0)

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
    }
}
    
// MARK: ZoomVideoSDKDelegate
// (3)
extension SessionViewController {
    
    func onSessionJoin() {
        // (4)
    }
    
    func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        // (8)
    }
    
    func onUserVideoStatusChanged(_ helper: ZoomVideoSDKVideoHelper?, user: [ZoomVideoSDKUser]?) {
        // (9)
    }
    
    func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, shareAction: ZoomVideoSDKShareAction?) {
        // (10)
    }
    
    func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users: [ZoomVideoSDKUser]?) {
        // (11)
    }
    
    func onSessionLeave() {
        // (14)
        
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: Convenience method
    private func getStartShareAction(_ user: ZoomVideoSDKUser) -> ZoomVideoSDKShareAction? {
        // (12)
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

            tabBar.items![ControlOption.toggleVideo.rawValue].isEnabled = true
            return
            
        case ControlOption.toggleAudio.rawValue:
            tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = false
            
            // (6)
            
            tabBar.items![ControlOption.toggleAudio.rawValue].isEnabled = true
            return
            
        case ControlOption.shareScreen.rawValue:
            tabBar.items![ControlOption.shareScreen.rawValue].isEnabled = false
            
            // (7)
            
            tabBar.items![ControlOption.shareScreen.rawValue].isEnabled = true
            return
            
        case ControlOption.endSession.rawValue:
            tabBar.isUserInteractionEnabled = false
            
            // (13)
            return
            
        default:
            return
        }
    }
}
