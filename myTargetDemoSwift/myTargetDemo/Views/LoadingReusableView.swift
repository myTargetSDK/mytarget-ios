//
//  LoadingReusableView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 13/05/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

import UIKit

class LoadingReusableView: UICollectionReusableView
{
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	override func awakeFromNib()
	{
        super.awakeFromNib()
    }
}
