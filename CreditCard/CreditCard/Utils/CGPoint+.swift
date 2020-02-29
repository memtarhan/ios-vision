//
//  CGPoint+.swift
//  CreditCard
//
//  Created by Mehmet Tarhan on 29.02.2020.
//  Copyright © 2020 Mehmet Tarhan. All rights reserved.
//

import UIKit

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: x * size.width,
                       y: y * size.height)
    }
}
