//
//  VideoProgressView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06/08/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

final class VideoProgressView: UIView {
    var position: TimeInterval = 0.0 {
	    didSet {
    	    setNeedsLayout()
    	    layoutIfNeeded()
	    }
    }

    var points = [Double]() {
	    didSet {
    	    advertisingPoints.forEach { $0.view.removeFromSuperview() }
    	    advertisingPoints.removeAll()

    	    points.forEach { (point) in
	    	    guard point >= 0, point <= duration else {
                    return
                }

	    	    let view = UIView()
	    	    view.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
	    	    let advertisingPoint = AdvertisingPoint(point: point, view: view)
	    	    advertisingPoints.append(advertisingPoint)
	    	    addSubview(view)
    	    }
    	    setNeedsLayout()
    	    layoutIfNeeded()
	    }
    }

    private struct AdvertisingPoint {
	    let point: Double
	    let view: UIView
    }

    private let advertisingPointWidth: CGFloat = 3.0
    private var duration: TimeInterval = 0.0
    private var progressView = UIView()
    private var advertisingPoints = [AdvertisingPoint]()

    init(duration: TimeInterval) {
	    super.init(frame: .zero)
	    self.duration = duration
	    setupView()
    }

    required init?(coder: NSCoder) {
	    super.init(coder: coder)
	    setupView()
    }

// MARK: - private

    private func setupView() {
	    backgroundColor = UIColor.black.withAlphaComponent(0.4)
	    progressView.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
	    addSubview(progressView)
    }

// MARK: - layout

    override func layoutSubviews() {
	    super.layoutSubviews()

	    let width = frame.width
	    let height = frame.height
	    let progressWidth = (duration > 0) ? width * CGFloat(position) / CGFloat(duration) : 0
	    progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: height)

	    advertisingPoints.forEach { (advertisingPoint) in
    	    guard advertisingPoint.point >= 0, advertisingPoint.point <= duration else {
                return
            }

    	    let offsetX = (duration > 0) ? width * CGFloat(advertisingPoint.point) / CGFloat(duration) : 0
    	    advertisingPoint.view.frame = CGRect(x: offsetX, y: 0, width: advertisingPointWidth, height: height)
	    }
    }
}
