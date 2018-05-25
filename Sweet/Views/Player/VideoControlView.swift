//
//  VideoControlView.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/5/28.
//  Copyright © 2017年 linweibiao. All rights reserved.
//

import UIKit
import MediaPlayer

class ControlVView: UIView {
    
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var videoPlaySlider: UISlider! {
        didSet {
            videoPlaySlider.setThumbImage(#imageLiteral(resourceName: "Point"), for: .normal)
        }
    }

}

class ControlHView: UIView {
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var videoPlaySlider: UISlider! {
        didSet {
            videoPlaySlider.setThumbImage(#imageLiteral(resourceName: "Point"), for: .normal)
        }
    }
}

class SystemVolume {
    static let instance = SystemVolume()
    let volumeView = MPVolumeView.init()
     func getLastVolume(view: UIView) -> Float {
        var slider: UISlider!
        for view in volumeView.subviews where view is UISlider {
                slider = view as? UISlider
        }
        let volume = slider.value
        return volume
    }
    
    func setLastVolume(value: Float) {
        var slider: UISlider!
        for view in volumeView.subviews where view is UISlider {
            slider = view as? UISlider
        }
        slider.value = value
    }
}
