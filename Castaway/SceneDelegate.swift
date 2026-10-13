import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var game: GameViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let game = GameViewController()
        window.rootViewController = game
        window.backgroundColor = GameViewController.inkColor
        window.makeKeyAndVisible()
        self.window = window
        self.game = game
    }

    // Save and pause whenever the player leaves the app (home swipe, call, Control Center).
    func sceneWillResignActive(_ scene: UIScene) { game?.pauseGame() }
    func sceneDidEnterBackground(_ scene: UIScene) { game?.pauseGame() }
    func sceneDidBecomeActive(_ scene: UIScene) { game?.resumeAudio() }
}
