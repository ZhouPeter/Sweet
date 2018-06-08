//
//  StoryPokeView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryPokeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 10
        addSubview(blurView)
        blurView.fill(in: self)
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "戳住屏幕播放"
        label.font = UIFont.systemFont(ofSize: 12)
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(label)
        vibrancyView.align(.bottom, to: blurView, inset: 10)
        vibrancyView.centerX(to: blurView)
        label.fill(in: vibrancyView)
        
        let pokeImageView = UIImageView(image: #imageLiteral(resourceName: "Poke"))
        addSubview(pokeImageView)
//        pokeImageView.constrain(width: 100, height: 100)
        pokeImageView.align(.left, inset: 10)
        pokeImageView.align(.right, inset: 10)
        pokeImageView.align(.bottom, inset: 20)
        pokeImageView.align(.top, to: self)
        pokeImageView.centerX(to: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class StorySmallPokeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.clipsToBounds = true
        blurView.layer.cornerRadius = 5
        addSubview(blurView)
        blurView.fill(in: self)
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "戳住屏幕播放"
        label.font = UIFont.systemFont(ofSize: 8)
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(label)
        vibrancyView.align(.bottom, to: blurView, inset: 0)
        vibrancyView.centerX(to: blurView)
        label.fill(in: vibrancyView)
        
        let pokeImageView = UIImageView(image: #imageLiteral(resourceName: "Poke"))
        addSubview(pokeImageView)
        pokeImageView.align(.left, inset: 5)
        pokeImageView.align(.right, inset: 5)
        pokeImageView.align(.bottom, inset: 10)
        pokeImageView.align(.top, to: self)
        pokeImageView.centerX(to: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
