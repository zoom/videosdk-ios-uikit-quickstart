import UIKit
import ZoomVideoSDK

class StartViewController: UIViewController {
    var enterSessionButton: UIButton!

    private func setupSDK() {
        let initParams = ZoomVideoSDKInitParams()
        initParams.domain = "zoom.us"
        let sdkInitReturnStatus = ZoomVideoSDK.shareInstance()?.initialize(initParams)
        switch sdkInitReturnStatus {
        case .Errors_Success:
            print("SDK initialization succeeded")
        default:
            if let error = sdkInitReturnStatus {
                print("SDK initialization failed: \(error)")
                return
            }
        }
    }

    override func loadView() {
        super.loadView()
        enterSessionButton = UIButton(type: .system)
        enterSessionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enterSessionButton)
        NSLayoutConstraint.activate([
            enterSessionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterSessionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidLoad() {
        enterSessionButton.backgroundColor = .white
        enterSessionButton.layer.cornerRadius = 8
        enterSessionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        enterSessionButton.setTitle("Join Session", for: .normal)
        enterSessionButton.addTarget(self, action: #selector(enterButtonTapped(_:)), for: .touchUpInside)
        enterSessionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        setupSDK()
    }

    @IBAction func enterButtonTapped(_: UIButton) {
        enterSessionButton.isEnabled = false
        let sessionViewController = SessionViewController()
        sessionViewController.modalPresentationStyle = .fullScreen
        present(sessionViewController, animated: false)
        enterSessionButton.isEnabled = true
    }
}
