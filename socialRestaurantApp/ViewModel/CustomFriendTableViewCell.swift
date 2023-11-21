//
//  CustomFriendTableViewCell.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 08/11/2023.
//

import UIKit

class CustomFriendTableViewCell: UITableViewCell {
    var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 9.0
        view.layer.shadowOpacity = 1
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var friendNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var restaurantLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        // improve scrolling performance with an explicit shadow path
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath

        addSubview(cardView)
        cardView.addSubview(friendNameLabel)
        cardView.addSubview(restaurantLabel)
        //self.contentView.backgroundColor = .white
        self.backgroundColor = .clear
        setupView()
    }

    func setupView() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            friendNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            friendNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            friendNameLabel.heightAnchor.constraint(equalToConstant: 50),
            friendNameLabel.widthAnchor.constraint(equalToConstant: 250),
            
            restaurantLabel.topAnchor.constraint(equalTo: friendNameLabel.bottomAnchor, constant: 10),
            restaurantLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            restaurantLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -1)
            
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
