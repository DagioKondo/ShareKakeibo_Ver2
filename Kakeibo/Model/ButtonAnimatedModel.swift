//
//  ButtonAnimated.swift
//  DayVC
//
//  Created by 近藤大伍 on 2021/09/29.
//

import Foundation
import UIKit

class ButtonAnimatedModel{
    
    let withDuration:TimeInterval
    let delay:TimeInterval
    let options:UIView.AnimationOptions
    let transform:CGAffineTransform
    let alpha:CGFloat
    
    
    init(withDuration:TimeInterval,delay:TimeInterval,options:UIView.AnimationOptions,transform:CGAffineTransform,alpha:CGFloat) {
        
        self.withDuration = withDuration
        self.delay = delay
        self.options = options
        self.transform = transform
        self.alpha = alpha
        
    }
    
    func startAnimation(sender:UIButton){
        UIView.animate(withDuration: withDuration,
                       delay: delay,options: options,
                       animations: {() -> Void in
                        sender.transform = self.transform
                        sender.alpha = self.alpha
                       },
                       completion: nil
        )
    }
    
    func endAnimation(sender:UIButton){
        UIView.animate(withDuration: withDuration,delay: delay,options:options,
                       animations: {() -> Void in
                        sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        sender.alpha = 1
                       },
                       completion: nil
        )
    }
    
    
}
