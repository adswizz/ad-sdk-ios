//
//  UIViewController+Storyboard.swift
//  AdvancedPodcastExample
//
//  Created by Teodor Cristea on 04.09.2023.
//  Copyright © 2023 Adswizz. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func create<T>() -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.create()
    }
    
    func create<T>() -> T? {
        guard let vc = instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
            Log.error("Wrong VC!")
            return nil
        }
        return vc
    }
}
