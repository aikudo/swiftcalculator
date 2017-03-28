//
//  GraphViewController.swift
//  Calculator
//
//  Created by Linh Hoang on 3/21/17.
//  Copyright © 2017 Blue Fronted. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    //a function take CGFloat and return a Double
    
    var function: ((Double) -> Double?)?
    
    
    //need to review the shortcut
    func getY(x: CGFloat) -> CGFloat? {
        if let function = function {
            if let result  = function(Double(x)) {
                return CGFloat(result)
            }
            return nil
        }
        return nil
    }
    
    
    @IBOutlet weak var graphView: GraphView! {
        
        didSet  {
            let handler = #selector(GraphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: handler)
            graphView.addGestureRecognizer(pinchRecognizer)
            let moveOrigin = #selector(GraphView.moveOrigin(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: moveOrigin)
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
            
            
            let panning = #selector(GraphView.panning(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panning)
            panRecognizer.minimumNumberOfTouches = 1
            panRecognizer.maximumNumberOfTouches = 2
            graphView.addGestureRecognizer(panRecognizer)
            
            graphView.dataSource = self
            
            
        }
    }
    
}
