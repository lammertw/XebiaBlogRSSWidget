//
//  ArrowView.swift
//  XebiaBlog
//
//  Created by Lammert Westerhoff on 09/09/14.
//  Copyright (c) 2014 Lammert Westerhoff. All rights reserved.
//

import UIKit

@IBDesignable
class ArrowView: UIView {

    override func drawRect(rect: CGRect)
    {
        XebiaBlogStyleKit.drawArrow(rect, arrowStroke: tintColor)
    }

}
