//
//  ViewController.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 02/11/2023.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        
        let restaurantViewController = RestaurantViewController()
        let friendsViewController = FriendsViewController()
        
        restaurantViewController.tabBarItem = UITabBarItem(title: "Restaurants", image: UIImage(systemName: "fork.knife"), tag: 0)
        friendsViewController.tabBarItem = UITabBarItem(title: "Friends", image: UIImage(systemName: "person.3.sequence"), tag: 1)
        
        let restaurantNC = UINavigationController(rootViewController: restaurantViewController)
        let friendNC = UINavigationController(rootViewController: friendsViewController)
        
        viewControllers = [restaurantNC, friendNC]
        
        
        
        
    }


}

