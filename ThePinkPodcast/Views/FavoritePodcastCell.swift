//
//  FavoritePodcastCell.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/11/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    var imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    var nameLabel = UILabel()
    var artistNameLabel = UILabel()
    var stackView = UIStackView()
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            imageView.sd_setImage(with: URL(string: podcast.artworkUrl600 ?? ""))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    //MARK:- Setup Functions
    fileprivate func setup() {
        setupCell()
        
        setupNameLabel()
        setupArtistNameLabel()
        setupStackView()
        
        setupImageViewConstraints()
        setupStackViewContraints()
    }
    
    fileprivate func setupCell() {
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    fileprivate func setupNameLabel() {
        nameLabel.text = "Podcast Name"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    fileprivate func setupArtistNameLabel() {
        artistNameLabel.text = "Artist Name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupImageViewConstraints() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, constant: 0).isActive = true
    }
    
    fileprivate func setupStackView() {
        stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
    }
    
    fileprivate func setupStackViewContraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
