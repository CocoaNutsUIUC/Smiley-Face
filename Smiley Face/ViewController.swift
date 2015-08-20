//
//  ViewController.swift
//  Smiley Face
//
//  Created by Justin Loew on 8/20/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var faceView: FaceView! {
		didSet {
			faceView.dataSource = self
			// enable pinch gestures in the FaceView using its pinch() handler
			faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "pinch:"))
			faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handleHappinessChange:"))
		}
	}
	var happiness = 0 { // 0 for sad, 100 for happy
		didSet {
			faceView.setNeedsDisplay()
		}
	}
	
	func handleHappinessChange(gesture: UIPanGestureRecognizer) {
		if gesture.state == .Changed || gesture.state == .Ended {
			let translationAmount = gesture.translationInView(faceView)
			happiness += Int(translationAmount.y / 2)
			if happiness < 0 {
				happiness = 0
			}
			if happiness > 100 {
				happiness = 100
			}
			gesture.setTranslation(CGPointZero, inView: faceView)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func shouldAutorotate() -> Bool {
		faceView.setNeedsDisplay()
		return true // support all orientations
	}
	
}

// MARK: - FaceViewDataSource
extension ViewController: FaceViewDataSource {
	func smileForFaceView(sender: FaceView) -> CGFloat {
		// happiness is 0-100. The range for the smile is -1 to 1.
		return CGFloat(happiness - 50) / 50.0
	}
}
