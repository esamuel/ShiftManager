import UIKit
import SwiftUI

class AppCoordinator {
    private let window: UIWindow
    private var navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let homeViewModel = HomeViewModel()
        let homeView = HomeView(viewModel: homeViewModel)
        let homeViewController = UIHostingController(rootView: homeView)
        
        navigationController.pushViewController(homeViewController, animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
} 