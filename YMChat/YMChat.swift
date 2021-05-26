import UIKit

@objc public protocol YMChatDelegate: AnyObject {
    @objc func onEventFromBot(response: YMBotEventResponse)
}

@objc public class YMChat: NSObject, YMChatViewControllerDelegate {
    @objc public static var shared = YMChat()
    @objc public var delegate: YMChatDelegate?

    @objc public var enableLogging = false

    @objc public var viewController: YMChatViewController?
    @objc public var config: YMConfig!

    func validateConfig() throws {
        if config == nil {
            throw NSError(domain: "Config is nil. Set config before invoking startChatbot", code: 0, userInfo: nil)
        }
        if config.botId.isEmpty {
            throw NSError(domain: "Bot id is not set", code: 0, userInfo: nil)
        }
        try JSONSerialization.data(withJSONObject: config.payload, options: [])
    }

    @objc public func startChatbot(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) throws {
        try validateConfig()
        self.viewController = YMChatViewController(config: config)
        self.viewController?.delegate = self
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }

    @objc public func startChatbot(animated: Bool = true, completion: (() -> Void)? = nil) throws {
        guard let vc = UIApplication.shared.windows.last?.rootViewController else {
            assertionFailure("View controller not found. Use presentView(on:animated:completion)")
            return
        }
        try startChatbot(on: vc, animated: animated, completion: completion)
    }

    @objc public func closeBot() {
        viewController?.dismiss(animated: false, completion: {
            self.viewController = nil
        })
    }

    // MARK: - YMChatViewControllerDelegate
    func eventReceivedFromBot(code: String, data: String?) {
        delegate?.onEventFromBot(response: YMBotEventResponse(code: code, data: data))
    }
}
