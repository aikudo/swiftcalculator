
//  GraphView.swift/Users/linh/Dropbox/iOS/developer/Calculator3/Calculator/GraphView.swift
//  Calculator
//
//  Created by Linh Hoang on 3/21/17.
//  Copyright © 2017 Blue Fronted. All rights reserved.
//

import UIKit

// we need a protocol support to get data from the controller

protocol GraphViewDataSource {
    func getY(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var scale: CGFloat = 1 {didSet {setNeedsDisplay()}}
    
    @IBInspectable
    var origin: CGPoint = CGPoint(x: 4, y:5) {didSet {setNeedsDisplay()}}
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default: break
            
        }
//        NSLog("scaled: \(scale)")
    }
    
    func panning(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            let newLocation = pinchRecognizer.location(in: self)
            origin = newLocation
        default: break
        }
    }
    
    func moveOrigin(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            let newLocation = pinchRecognizer.location(in: self)
            origin = newLocation
        default: break
            
        }
    }
    
    private var axisGrid = AxesDrawer()
    
    func plot() {
        
        let startX = Int(bounds.minX)
        let endX = Int(bounds.maxX)
        
        let path = UIBezierPath()
        var startingPoint = false
        //        NSLog("plotting from \(startX) to \(endX)")
        for x in startX..<endX {
            if let y  = dataSource?.getY(x: CGFloat(x) - origin.x) {
                
                if !y.isNormal && !y.isZero {
                    startingPoint = false
                    continue
                }
                
                let newPoint  = CGPoint(x: CGFloat(x), y: origin.y - y)
                
                if startingPoint {
                    path.addLine(to: newPoint)
                } else {
                    path.move(to: newPoint)
                    startingPoint = true
                }
                //                NSLog("\(x), \(y)")
                
            }
            
        }
        UIColor.red.setStroke() // note setStroke is a method in UIColor, not UIBezierPath
        path.stroke()
        
    } //end plot function
    
    
    private var radius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2
    }
    

    private func drawAxis() {
        let rect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        axisGrid.drawAxes(in: rect, origin: origin, pointsPerUnit: 50 * scale)
    }

    override func draw(_ rect: CGRect) {
        let radius =  min(bounds.size.width, bounds.size.height) / 2
        //        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0,
                                endAngle: 2.0 * CGFloat.pi, clockwise: false)
        path.lineWidth = 5
        path.stroke()
        
        drawAxis()
        plot()
    }
}
