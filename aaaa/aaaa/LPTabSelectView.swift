//
//  LPTabSelectView.swift
//  MaiYa
//
//  Created by 路鹏 on 2018/9/17.
//  Copyright © 2018年 LP. All rights reserved.
//

import UIKit

protocol LPTabSelectViewDelegate: class {
    func didSelected(index: Int)
}

class LPTabSelectViewCfg: NSObject {
    //布局属性
    var isAutoDistance:Bool! = true;//自适应会根据minDistance的值，计算self.width小于字符串和间距总宽度则会滑动展示，大于则会根据self.width平分
    var titleIsCenter:Bool! = false;//true的话会根据minDistance来设置间距，两边自适应,头部居中，headLeftInset，headRightInset无效
    var isUseLine:Bool! = true;//false的话不会有渐变效果，只有选中效果
    
    //展示属性
    var minDistance:CGFloat! = 15;//间距
    var headLeftInset:CGFloat! = 0;//左边间距
    var headRightInset:CGFloat! = 0;//右间距
    var headHeight:CGFloat! = 40;//头部高度
    var lineViewWidth:CGFloat! = 15;//线条宽度
    var lineViewHeight:CGFloat! = 3;//线条高度
    var lineViewBootm:CGFloat! = 6;//线条距离头部底部间距
    var lineColor:UIColor! = UIColor.init(hex: "FB4351");//线条颜色
    var selectColor:UIColor! = UIColor.init(hex: "FB4351");//标题选中颜色
    var normalColor:UIColor! = UIColor.init(hex: "333333");//标题默认颜色
    var selectFont:CGFloat! = 20;//标题选中字号
    var normalFont:CGFloat! = 14;//标题默认字号
    var titleFont:UIFont! = UIFont.systemFont(ofSize: 14);//标题字体
    var titleBgColor:UIColor! = UIColor.init(hex: "fc4351");//isUseLine为false时选中背景色
}

class LPTabSelectView: UIView {
    
    var cfg:LPTabSelectViewCfg!;
    var vcArr:[UIViewController]! = [];
    var titleArr:[String]! = [];
    weak var bgVC:UIViewController!;
    var redLine:UIView!;
    var itemArr:[UIButton]! = [];
    var headScrollView:UIScrollView!;
    var contentScrollView:LPTabSelectScrollView!;
    var colorArr:[UIColor]! = [];
    weak var delegate: LPTabSelectViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    /**
     *dataArr:["title":[String], "vc":[UIViewController]]
     */
    init(frame: CGRect, dataArr:[String:Any]!,viewCfg:LPTabSelectViewCfg!, bgVC:UIViewController!) {
        super.init(frame: frame);
        if let titleArr = dataArr["title"] as? [String] {
            self.titleArr = titleArr;
        }
        
        if let vcArr = dataArr["vc"] as? [UIViewController] {
            self.vcArr = vcArr;
        }
        
        self.cfg = viewCfg;
        
        self.bgVC = bgVC;
        self.createSubView();
    }
    
    override func didMoveToSuperview() {
        self.bgVC.automaticallyAdjustsScrollViewInsets = false;
        let gestureArr = self.bgVC.navigationController?.view.gestureRecognizers;
        for gestureRecognizer in gestureArr ?? [] {
            if (gestureRecognizer is UIScreenEdgePanGestureRecognizer) {
                self.contentScrollView.panGestureRecognizer.require(toFail: gestureRecognizer);
            }
        }
    }
    
    func createSubView(){
        let headScrollView = UIScrollView();
        headScrollView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.cfg.headHeight);
        headScrollView.showsHorizontalScrollIndicator = false;
        self.addSubview(headScrollView);
        self.headScrollView = headScrollView;
        
        var allW:CGFloat = 0;
        var sAllW:CGFloat = 0;
        for item in self.titleArr {
            let s = NSString.init(string: item);
            let w = s.boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: 100), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue), attributes:[NSAttributedStringKey.font:self.cfg.titleFont], context: nil).width;
            sAllW += w;
            allW += (w+self.cfg.minDistance);
        }
        if (self.cfg.titleIsCenter) {
            let inset = (self.frame.size.width - allW) / 2.0;
            self.cfg.headLeftInset = inset;
            self.cfg.headRightInset = inset;
        }
        allW += self.cfg.headLeftInset+self.cfg.headRightInset;
        
        if (allW < self.frame.size.width && self.cfg.isAutoDistance) {
            self.cfg.minDistance = (self.frame.size.width-self.cfg.headLeftInset-self.cfg.headRightInset-sAllW)/CGFloat(self.titleArr.count);
            allW = self.frame.size.width;
        }
        headScrollView.contentSize = CGSize.init(width: allW, height: 0);
        
        let scrollView = LPTabSelectScrollView();
        scrollView.frame = CGRect.init(x: 0, y: self.cfg.headHeight, width: self.frame.size.width, height: self.frame.size.height-self.cfg.headHeight);
        scrollView.isPagingEnabled = true;
        scrollView.delegate = self;
        scrollView.backgroundColor = UIColor.init(hex: "F2F2F2");
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.contentSize = CGSize.init(width: self.frame.size.width*CGFloat(self.titleArr.count), height: 0);
        self.addSubview(scrollView);
        self.contentScrollView = scrollView;
        
        var lastBtnR:CGFloat! = self.cfg.headLeftInset;
        var firstCenterX:CGFloat = 0;
        for (i,item) in self.titleArr.enumerated() {
            let s = NSString.init(string: item);
            let w = s.boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: 100), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedStringKey.font:self.cfg.titleFont], context: nil).width
            var itemW:CGFloat = 0;
            itemW = w+self.cfg.minDistance;
            let btn = self.cfg.isUseLine ? UIButton.init(type: .custom) : LPTabSelectBtn.init(type: .custom);
            btn.frame = CGRect.init(x: lastBtnR, y: 0, width: itemW, height: self.cfg.headHeight);
            lastBtnR = btn.frame.origin.x + btn.frame.size.width;
            btn.setTitle(item, for: .normal);
            btn.setTitleColor(i == 0 ? self.cfg.selectColor : self.cfg.normalColor, for: .normal);
            btn.titleLabel?.font = self.cfg.titleFont;
            if (i == 0) {
                if (!self.cfg.isUseLine) {
                    btn.titleLabel?.font = UIFont.init(name: self.cfg.titleFont.fontName, size: self.cfg.selectFont);
                }else {
                    btn.transform = CGAffineTransform.init(scaleX: self.cfg.selectFont/self.cfg.normalFont, y: self.cfg.selectFont/self.cfg.normalFont)
                }
                
                firstCenterX = btn.center.x;
            }
            btn.addTarget(self, action: #selector(self.btnClick), for: .touchUpInside);
            btn.tag = i;
//            btn.backgroundColor = UIColor.init(red: CGFloat(arc4random()%255) / 255.0, green: CGFloat(arc4random()%255) / 255.0, blue: CGFloat(arc4random()%255) / 255.0, alpha: 1)
            headScrollView.addSubview(btn);
            self.itemArr.append(btn);
            
            if (!self.cfg.isUseLine) {
                if let redBtn = btn as? LPTabSelectBtn {
                    redBtn.bgViewCloor = self.cfg.titleBgColor;
                }
            }
            
        }
        
        let redLine = UIView();
        redLine.frame = CGRect.init(x: 0, y: self.cfg.headHeight-self.cfg.lineViewBootm-self.cfg.lineViewHeight, width: self.cfg.lineViewWidth, height: self.cfg.lineViewHeight);
        redLine.center.x = firstCenterX;
        redLine.layer.cornerRadius = 1.5;
        redLine.backgroundColor = self.cfg.lineColor;
        headScrollView.addSubview(redLine);
        self.redLine = redLine;
        
        if (!self.cfg.isUseLine) {
            redLine.alpha = 0;
        }

        self.colorArr = self.getColorArr(startR: self.cfg.selectColor.red()*255, startG: self.cfg.selectColor.green()*255, startB: self.cfg.selectColor.blue()*255, endR: self.cfg.normalColor.red()*255, endG: self.cfg.normalColor.green()*255, endB: self.cfg.normalColor.blue()*255, step: 100);
        
        self.btnClick(sender: self.itemArr[0]);
        
    }
    
    @objc func btnClick(sender:UIButton) {
        if (!self.cfg.isUseLine) {
            for item in self.itemArr {
                if let btn = item as? LPTabSelectBtn {
                    btn.isChoose = false;
                    btn.setTitleColor(self.cfg.normalColor, for: .normal);
                    btn.titleLabel?.font = UIFont.init(name: self.cfg.titleFont.fontName, size: self.cfg.normalFont);
                }
            }
            if let btn = sender as? LPTabSelectBtn {
                btn.isChoose = true;
                btn.setTitleColor(self.cfg.selectColor, for: .normal);
                btn.titleLabel?.font = UIFont.init(name: self.cfg.titleFont.fontName, size: self.cfg.selectFont);
            }
        }
        
        self.contentScrollView.setContentOffset(CGPoint.init(x: self.frame.size.width*CGFloat(sender.tag), y: 0), animated: true);
        self.moveToCenter(view: sender);
        
        let vc = self.vcArr[sender.tag];
        vc.view.frame = CGRect.init(x: CGFloat(sender.tag)*self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height-self.cfg.headHeight);
        self.bgVC.addChildViewController(vc);
        self.contentScrollView.addSubview(vc.view);
        self.delegate?.didSelected(index: sender.tag)
    }
}

extension LPTabSelectView:UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.cfg.isUseLine) {
            self.setTitleColor();
            self.setLineFrame();
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let count = Int(scrollView.contentOffset.x/self.frame.size.width);
        self.btnClick(sender: self.itemArr[count]);
    }
    
}
extension LPTabSelectView{
    func getColorArr(startR:CGFloat,startG:CGFloat,startB:CGFloat,endR:CGFloat,endG:CGFloat,endB:CGFloat,step:Int) -> [UIColor] {
        var arr:[UIColor] = [];
        let sR:CGFloat = (endR-startR)/CGFloat(step);
        let sG:CGFloat = (endG-startG)/CGFloat(step);
        let sB:CGFloat = (endB-startB)/CGFloat(step);
        for i in 0..<step {
            var color = UIColor.init(red: (sR*CGFloat(i)+startR)/255, green: (sG*CGFloat(i)+startG)/255, blue: (sB*CGFloat(i)+startB)/255, alpha: 1);
            if (i == 0) {color = UIColor.init(red: startR/255, green: startG/255, blue: startB/255, alpha: 1)}
            if (i == step-1) {color = UIColor.init(red: endR/255, green: endG/255, blue: endB/255, alpha: 1)}
            arr.append(color);
        }
        return arr;
    }
    
    func setTitleColor(){
        let e = self.contentScrollView.contentOffset.x/self.frame.size.width;
        if (e < 0) {
            return;
        }
        let contentOfsetFloat = e-CGFloat(Int(e));
        let count = Int(e);
        var leftItemObj:UIButton = self.itemArr[count];
        var rightItemObj:UIButton = self.itemArr[count];
        var leftColor:UIColor!;
        var rightColor:UIColor!;
        var leftScale:CGFloat! = 1;
        var rightScale:CGFloat! = 1;
        
        if (e.truncatingRemainder(dividingBy: 1.0) != 0 && e<=CGFloat(self.itemArr.count-1)) {
            leftItemObj = self.itemArr[count];
            rightItemObj = self.itemArr[count+1];
        }
        leftColor = self.cfg.normalColor;
        rightColor = self.cfg.normalColor;
        
        if (leftItemObj == rightItemObj) {
            leftColor = self.cfg.selectColor;
            rightColor = self.cfg.selectColor;
            leftScale = self.cfg.selectFont/self.cfg.normalFont;
            rightScale = self.cfg.selectFont/self.cfg.normalFont;
            for i in 0..<self.itemArr.count {
                if (i != count) {
                    self.itemArr[i].setTitleColor(self.cfg.normalColor, for: .normal);
                    self.itemArr[i].transform = CGAffineTransform.init(scaleX: 1, y: 1);
                }
            }
        }else {
            leftColor = self.colorArr[Int(contentOfsetFloat*100)];
            rightColor = self.colorArr[Int(CGFloat(100)-contentOfsetFloat*100)]
            
            leftScale = self.cfg.selectFont/self.cfg.normalFont - CGFloat(fabs(self.cfg.selectFont/self.cfg.normalFont - 1))*contentOfsetFloat;
            rightScale = 1 + CGFloat(fabs(self.cfg.selectFont/self.cfg.normalFont - 1))*contentOfsetFloat;
        }
        leftItemObj.setTitleColor(leftColor, for: .normal);
        rightItemObj.setTitleColor(rightColor, for: .normal);
        leftItemObj.transform = CGAffineTransform.init(scaleX: leftScale, y: leftScale);
        rightItemObj.transform = CGAffineTransform.init(scaleX: rightScale, y: rightScale);
    }
    
    func setLineFrame(){
        let contentOffsetX = self.contentScrollView.contentOffset.x/self.frame.size.width;
        var contentWidth:CGFloat = 0;
        var lineLeft:CGFloat = 0;
        var lineRight:CGFloat = 0;
        
        contentWidth =  self.frame.size.width;
        let count = Int(contentOffsetX);
        var leftItemObj = self.itemArr[count];
        var rightItemObj = self.itemArr[count];
        if (contentOffsetX.truncatingRemainder(dividingBy: 1.0) != 0 && contentOffsetX >= 0 && contentOffsetX <= CGFloat(self.itemArr.count-1)) {
            leftItemObj = self.itemArr[count];
            rightItemObj = self.itemArr[count+1];
        }
        if (leftItemObj == rightItemObj) {
            lineLeft = leftItemObj.center.x - self.cfg.lineViewWidth/2.0;
            lineRight = contentWidth-(leftItemObj.center.x+self.cfg.lineViewWidth/2.0)
        }else {
            if (contentOffsetX < (CGFloat(count)+0.5)){
                lineLeft = leftItemObj.center.x-self.cfg.lineViewWidth/2.0;
                lineRight = contentWidth-(leftItemObj.center.x+self.cfg.lineViewWidth/2.0);
                lineRight = lineRight-(contentOffsetX-CGFloat(count))*fabs(rightItemObj.center.x-leftItemObj.center.x)/0.5;
            }else {
                let fb = fabs(rightItemObj.center.x-leftItemObj.center.x)/0.5;
                lineLeft = leftItemObj.center.x-self.cfg.lineViewWidth/2.0+(contentOffsetX-CGFloat(count)-0.5)*fb;
                lineRight = contentWidth-(rightItemObj.center.x+self.cfg.lineViewWidth/2.0);
            }
        }
        
        self.redLine.frame = CGRect.init(x: lineLeft, y: self.redLine.frame.origin.y, width: (self.frame.size.width-lineLeft-lineRight), height: self.redLine.frame.size.height);
    }
    
    func moveToCenter(view:UIView) {
        let offsetX = view.center.x + self.frame.origin.x - self.frame.size.width/2;
        let maxSetX = self.headScrollView.contentSize.width-self.headScrollView.frame.size.width;
        
        if (maxSetX < 0) {
            self.headScrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true);
            return;
        }
        
        if (offsetX>0 && offsetX < maxSetX) {
            self.headScrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true);
            return;
        }
        
        if (offsetX < 0) {
            self.headScrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true);
            return;
        }
        
        if (offsetX > maxSetX) {
            self.headScrollView.setContentOffset(CGPoint.init(x: maxSetX, y: 0), animated: true);
            return;
        }
    }
}

class LPTabSelectScrollView:UIScrollView,UIGestureRecognizerDelegate {
    public var isOpenClash:Bool! = true;//trues滑动删除和滑动会冲突，fale会解决冲突
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (self.isOpenClash) {
            return true;
        }
        if (touch.view is UITableView) {
            return true;
        }
        return false;
    }
}

class LPTabSelectBtn:UIButton {
    
    public var bgView:UIView!;
    public var bgViewCloor:UIColor!
    public var isChoose:Bool! {
        didSet{
            if (isChoose) {
                self.bgView.backgroundColor = self.bgViewCloor;
            }else{
                self.bgView.backgroundColor = UIColor.clear;
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bgView = UIView();
        bgView.isUserInteractionEnabled = false;
        self.addSubview(bgView);
        self.bgView = bgView;
        bgView.sendSubview(toBack: bgView);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        self.bgView.bounds = CGRect.init(x: 0, y: 0, width: (self.titleLabel?.frame.size.width ?? 0) + 16, height: (self.titleLabel?.frame.size.height ?? 0) + 13)
        self.bgView.center = CGPoint.init(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0);
        self.bgView.layer.cornerRadius = self.bgView.frame.size.height/2.0;
        self.bgView.layer.masksToBounds = true;
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    func red()->CGFloat! {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return r
    }
    func green()->CGFloat! {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return g
    }
    func blue()->CGFloat! {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return b
    }
}
