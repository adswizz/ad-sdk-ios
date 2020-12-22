//
//  ViewController+VideoViewDelegate.swift
//  BasicVideoAdExample
//
//  Created by Teodor Cristea on 24/11/2020.
//

import UIKit
import Foundation

extension ViewController: VideoViewDelegate {
    func video(_ view: VideoView, didTapSkip button: UIButton) {
        model.skip()
    }
    
    func videoDidDoubleTap(_ view: VideoView) {
        view.animateFullScreenOrReverse(from: self.view)
    }
}
