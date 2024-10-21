//
//  GameCenter.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import GameKit

private enum SDGameCenterConstants {
    static let coinsLeaderboardID = "com.storedemo.leaderboard.coins"
}

class SDGameCenter: NSObject {
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
}

// MARK: - Public Methods

extension SDGameCenter {
    
    func authenticate(from presentingViewController: UIViewController, completion: @escaping (_ isAuthenticated: Bool) -> Void ) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController {
                // Present the view controller so the player can sign in.
                presentingViewController.present(viewController, animated: true)
                return
            }
            if error != nil {
                // Player could not be authenticated.
                completion(false)
                return
            }
            
            // Player was successfully authenticated.
            // Check if there are any player restrictions before starting the game.
            
            if GKLocalPlayer.local.isUnderage {
                // Hide explicit game content.
            }
            if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                // Disable multiplayer game features.
            }
            if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
                // Disable in game communication UI.
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                completion(true)
            }
            
            // Perform any other configurations as needed (for example, access point).
            GKAccessPoint.shared.location = .bottomLeading
            self?.showAccessPoint(showHighlights: true)
        }
    }
    
    func showAccessPoint(showHighlights: Bool) {
        GKAccessPoint.shared.showHighlights = showHighlights
        GKAccessPoint.shared.isActive = GKLocalPlayer.local.isAuthenticated
    }
    
    func hideAccessPoint() {
        GKAccessPoint.shared.showHighlights = false
        GKAccessPoint.shared.isActive = false
    }
}

// MARK: - Public Methods. Leaderboard

extension SDGameCenter {
    func show(state: GKGameCenterViewControllerState, from presentingViewController: UIViewController) {
        let viewController = GKGameCenterViewController(state: state)
        viewController.gameCenterDelegate = self
        presentingViewController.present(viewController, animated: true, completion: nil)
    }
    
    func submitCoins(_ coins: Int, completion: ((_ submitted: Bool) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        GKLeaderboard.submitScore(coins, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [SDGameCenterConstants.coinsLeaderboardID]) { error in
            completion?(error == nil)
            if let error {
                print("GKLeaderboard submitting coins error \(error)")
            }
        }
    }
}

// MARK: - GKGameCenterControllerDelegate

extension SDGameCenter: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
