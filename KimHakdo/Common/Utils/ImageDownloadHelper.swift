//
//  ImageDownloadHelper.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/4/25.
//

import Foundation
import Kingfisher

enum ImageDownloadHelper {
    
    static let options = {
        let modifier = AnyModifier { request in
            var request = request
            let (authorization, token) = Router.Headers.authorization.header
            let (sesacKey, key) = Router.Headers.sesacKey.header
            request.setValue(token, forHTTPHeaderField: authorization)
            request.setValue(key, forHTTPHeaderField: sesacKey)
            return request
        }
        
        let processor = DownsamplingImageProcessor(
            size: CGSize(width: Constants.deviceWidth, height: Constants.deviceWidth * 0.75)
        )
        
        let options: KingfisherOptionsInfo = [
            .requestModifier(modifier),
            .processor(processor),
            .scaleFactor(Constants.deviceScale)
        ]
        return options
    }()
    
}
