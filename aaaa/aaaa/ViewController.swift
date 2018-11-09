//
//  ViewController.swift
//  aaaa
//
//  Created by 路鹏 on 2018/11/9.
//  Copyright © 2018 路鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataArr:[String : Any] = [
            "title":["精选","每日爆款","内衣",],
            "vc":[ListVC(),ListVC(),ListVC(),ListVC(),ListVC(),ListVC(),ListVC(),ListVC(),ListVC(),ListVC()],
            ]
        let cfg = LPTabSelectViewCfg()
        cfg.selectColor = UIColor.blue;
        let head = LPTabSelectView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64), dataArr: dataArr, viewCfg: cfg, bgVC: self)
        self.view.addSubview(head)
    }


}

