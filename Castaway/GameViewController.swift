import UIKit
import WebKit

/// Hosts the game (Game/index.html, bundled in the app) in a full-screen web view.
final class GameViewController: UIViewController {
    static let inkColor = UIColor(red: 15/255, green: 19/255, blue: 17/255, alpha: 1)
    static let scheme = "castaway"

    private var webView: WKWebView!
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)

    // The game already calls Capacitor's Haptics plugin when it exists, so we provide one with the same shape.
    private static let bridgeJS = """
    window.__castawayNative = true;
    window.Capacitor = window.Capacitor || {};
    window.Capacitor.Plugins = window.Capacitor.Plugins || {};
    window.Capacitor.Plugins.Haptics = { impact: function (o) {
      try { window.webkit.messageHandlers.haptic.postMessage((o && o.style) || 'LIGHT'); } catch (e) {}
    } };
    """

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(BundleSchemeHandler(), forURLScheme: Self.scheme)
        config.websiteDataStore = .default()          // keeps the save game (localStorage) between launches
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = true

        let content = config.userContentController
        content.add(WeakMessageHandler(self), name: "haptic")
        content.addUserScript(WKUserScript(source: Self.bridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = Self.inkColor
        web.scrollView.backgroundColor = Self.inkColor
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.scrollView.minimumZoomScale = 1
        web.scrollView.maximumZoomScale = 1
        web.scrollView.delegate = self
        web.navigationDelegate = self
        web.allowsLinkPreview = false
        #if DEBUG
        if #available(iOS 16.4, *) { web.isInspectable = true }   // Safari > Develop menu, for debugging only
        #endif
        webView = web
        view = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Self.inkColor
        lightHaptic.prepare()
        if let url = URL(string: "\(Self.scheme)://localhost/index.html") {
            webView.load(URLRequest(url: url))
        }
    }

    // Full-screen landscape game: no status bar, home indicator fades out, edge swipes need a second swipe.
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }

    func pauseGame() {
        webView?.evaluateJavaScript("window.castawayPause && window.castawayPause()", completionHandler: nil)
    }

    func resumeAudio() {
        webView?.evaluateJavaScript("window.castawayResume && window.castawayResume()", completionHandler: nil)
    }
}

extension GameViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "haptic" else { return }
        switch (message.body as? String)?.uppercased() {
        case "HEAVY": heavyHaptic.impactOccurred()
        case "MEDIUM": mediumHaptic.impactOccurred()
        default: lightHaptic.impactOccurred()
        }
    }
}

extension GameViewController: WKNavigationDelegate {
    // iOS can kill the web content process under memory pressure; reload (the game autosaves every few seconds).
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

extension GameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { nil }
}

/// Avoids a retain cycle between the web view's content controller and this view controller.
private final class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(_ target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}
