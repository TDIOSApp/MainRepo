//
//  AnimationSupport.swift
//  VPN
//
//  Created by Ohir on 11.06.2021.
//

import Foundation
import Lottie

func lottieAnimationInit(animView : AnimationView){
    animView.loopMode = .loop
    animView.play()
    animView.isHidden = false
}

func lottieAnimationStop(animView : AnimationView){
    animView.stop()
    animView.isHidden = true
}

func lottieAnimationStart(animView : AnimationView){
    animView.play()
    animView.isHidden = false
}
