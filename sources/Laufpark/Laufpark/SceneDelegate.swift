//
//  SceneDelegate.swift
//  Laufpark
//
//  Created by Ankui on 12/11/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mapViewController: ViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        mapViewController = ViewController()
        window?.rootViewController = mapViewController
        window?.makeKeyAndVisible()
//        DispatchQueue.global().async {
        DispatchQueue(label: "Track Loading").async {
            let tracks = self.loadTracks()
            DispatchQueue.main.async {
                self.mapViewController?.setTracks(tracks)
            }
        }
    }

    func loadTracks() -> [Track] {
        let definitions: [(Color, Int)] = [
            (.red, 4),
            (.turquoise, 5),
            (.brightGreen, 7),
            (.beige, 2),
            (.green, 4),
            (.purple, 3),
            (.violet, 4),
            (.blue, 3),
            (.brown, 4),
            (.yellow, 4),
            (.gray, 0),
            (.lightBlue, 4),
            (.lightBrown, 5),
            (.orange, 0),
            (.pink, 4),
            (.lightPink, 6)
        ]
        var allTracks: [[Track]] = []
        
        time {
            allTracks = definitions.map { (color, cout) in
                let trackNames: [(Int, String)] = (0...cout).map { ($0, "wabe \(color.name)-strecke \($0)") }
                return trackNames.map { numberAndName -> Track in
                    let reader = TrackReader(url: Bundle.main.url(forResource: numberAndName.1, withExtension: "gpx")!)!
                    return Track(color: color, number: numberAndName.0, name: reader.name, points: reader.points)
                }
            }
        }
        return Array(allTracks.joined())
    }
    
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

