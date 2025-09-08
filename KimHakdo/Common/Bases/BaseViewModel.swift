//
//  BaseViewModel.swift
//  KimHakdo
//
//  Created by 김영훈 on 9/2/25.
//

import Foundation

protocol BaseViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
