//
//  FaceView.swift
//  Smiley Face
//
//  Created by Justin Loew on 8/20/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit

protocol FaceViewDataSource {
	func smileForFaceView(sender: FaceView) -> CGFloat
}

class FaceView: UIView {
	
	var dataSource: FaceViewDataSource?
	var scale: CGFloat = 0.90 {
		// didSet is called every time scale is set (after it has the new value)
		didSet {
			// don't allow zero scale
			if scale == 0 {
				scale = 0.90
			}
			// any time our scale changes, call for redraw
			setNeedsDisplay()
		}
	}
	
	func drawCircleAtPoint(p: CGPoint, withRadius r: CGFloat, inContext context: CGContextRef) {
		UIGraphicsPushContext(context)
		
		CGContextBeginPath(context)
		CGContextAddArc(context, p.x, p.y, r, 0.0, CGFloat(2*M_PI), 1)
		CGContextStrokePath(context)
		
		UIGraphicsPopContext()
	}
	
	func pinch(gesture: UIPinchGestureRecognizer) {
		if gesture.state == .Changed || gesture.state == .Ended {
			scale *= gesture.scale // adjust our scale
			gesture.scale = 1 // reset the gesture's scale to 1 (so future changes are incremental, not cumulative)
		}
	}
	
	// Only override drawRect: if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func drawRect(rect: CGRect) {
		// Drawing code
		let context = UIGraphicsGetCurrentContext()!
		
		// The `self.` in `self.bounds` could be omitted, but is included here to show that `bounds` is a property of self.
		let midpoint = CGPoint(x: self.bounds.origin.x + self.bounds.size.width/2, y: self.bounds.origin.y + self.bounds.size.height/2)
		
		let faceSize: CGFloat
		if self.bounds.size.width < self.bounds.size.height {
			faceSize = self.bounds.size.width / 2 * scale
		} else {
			faceSize = self.bounds.size.height / 2 * scale
		}
		
		// set up how we want our lines to look
		CGContextSetLineWidth(context, 5)
		UIColor.blueColor().setStroke()
		
		drawCircleAtPoint(midpoint, withRadius: faceSize, inContext: context)  // draw the circle around the face
		
		// draw the eyes
		let eye_h: CGFloat = 0.35
		let eye_v: CGFloat = 0.35
		let eye_radius: CGFloat = 0.1
		var eyePoint = CGPoint(x: midpoint.x - faceSize*eye_h, y: midpoint.y - faceSize*eye_v)
		drawCircleAtPoint(eyePoint, withRadius: faceSize*eye_radius, inContext: context) // left eye
		eyePoint.x += faceSize * eye_h * 2
		drawCircleAtPoint(eyePoint, withRadius: faceSize*eye_radius, inContext: context) // right eye
		
		// prepare the corners of the mouth
		let mouth_h: CGFloat = 0.45
		let mouth_v: CGFloat = 0.45
		let mouth_smile: CGFloat = 0.25
		let mouthStart = CGPoint(x: midpoint.x - mouth_h*faceSize, y: midpoint.y + mouth_v*faceSize)
		var mouthEnd = mouthStart
		mouthEnd.x += mouth_h * faceSize * 2
		var mouthCP1 = mouthStart
		mouthCP1.x += mouth_h * faceSize * 2/3
		var mouthCP2 = mouthEnd
		mouthCP2.x -= mouth_h * faceSize * 2/3
		// get the size of the smile, between -1 and 1
		var smile = dataSource!.smileForFaceView(self)
		if smile < -1 {
			smile = -1
		}
		if smile > 1 {
			smile = 1
		}
		let smile_offset = mouth_smile * faceSize * smile
		mouthCP1.y += smile_offset
		mouthCP2.y += smile_offset
		// draw the mouth
		CGContextBeginPath(context)
		CGContextMoveToPoint(context, mouthStart.x, mouthStart.y)
		CGContextAddCurveToPoint(context, mouthCP1.x, mouthCP1.y, mouthCP2.x, mouthCP2.y, mouthEnd.x, mouthEnd.y) // bezier curve
		CGContextStrokePath(context)
	}
	
}
