//
//  ImageCollectionViewCell.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ImageCollectionViewCell: BaseCollectionViewCell<String> {
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func setData(data: String) {
        let url = try? Router.fetchImage(url: data).asURL()
        imageView.kf.setImage(with: url, options: ImageDownloadHelper.options)
    }
    
    override func setupHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
