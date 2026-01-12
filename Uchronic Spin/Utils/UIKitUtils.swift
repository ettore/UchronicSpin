//
//  UIKitUtils.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 1/12/26.
//  Copyright © 2026 Ettore Pasquini. All rights reserved.
//

import UIKit


extension UIApplication: AppOpener {
    func open(_ url: URL) async {
        await open(url, options: [:])
    }
}
