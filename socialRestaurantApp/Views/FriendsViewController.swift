//
//  FriendsViewController.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 03/11/2023.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var firebaseDB =  FirebaseDB()
    var friends = [Friends]()
    var friendRestaurantList = [Restaurants]()
    
    
    let cellReuseIdentifier = "Cell"
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    let tableViewRowHeight = 150.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        firebaseDB.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: NSNotification.Name("com.user.loggedOut"), object: nil)
        
        setupTableView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            DispatchQueue.global(qos: .userInteractive).async {
                self.firebaseDB.getFriendsData()
            }
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(CustomFriendTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func loadFriends(friendsRestaurant: [Restaurants]) {
        friendRestaurantList = friendsRestaurant
        tableView.reloadData()
    }
    
    @objc func addFriend() {
        let ac = UIAlertController(title: "Enter friends email address", message: nil, preferredStyle: .alert)
        ac.addTextField()
        var friendExists = false
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { alertAction in
            guard let email = ac.textFields![0].text?.uppercased() else { return }
            if self.isValidEmail(email) {
                if self.checkFriendExists(email: email) {
                    print("exists")
                } else {
                    self.firebaseDB.uploadFriends(email: email)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func checkFriendExists(email: String) -> Bool {
        for i in friends {
            if i.Email.uppercased() == email.uppercased() {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    @objc func userLoggedOut() {
        friends.removeAll()
        friendRestaurantList.removeAll()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRestaurantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CustomFriendTableViewCell
        cell.selectionStyle = .none
        cell.friendNameLabel.text = friendRestaurantList[indexPath.row].email.lowercased()
        cell.restaurantLabel.text = friendRestaurantList[indexPath.row].restaurantName

        return cell
    }
    
    // check if email is valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
