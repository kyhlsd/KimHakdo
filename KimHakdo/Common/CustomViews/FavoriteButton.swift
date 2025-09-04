//
//  FavoriteButton.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit

final class FavoriteButton: UIButton {
    
    func setStatus(isFavorited: Bool) {
        let image: UIImage = isFavorited ? .likeButtonFill : .likeButton
        let config = UIImage.SymbolConfiguration(scale: .large)
        let resized = image.applyingSymbolConfiguration(config)
        setImage(resized, for: .normal)
    }
    
    func setStatusWithBorder(isFavorited: Bool) {
        let image = UIImage(systemName: isFavorited ? "heart.fill" : "heart")
        tintColor = isFavorited ? .point : .border
        let config = UIImage.SymbolConfiguration(scale: .large)
        let resized = image?.applyingSymbolConfiguration(config)
        setImage(resized, for: .normal)
    }
}
