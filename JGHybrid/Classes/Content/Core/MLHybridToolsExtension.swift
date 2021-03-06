//
//  MLHybridToolsExtension.swift
//  JGHybrid
//
//  Created by 李保君 on 2017/11/24.
//

import UIKit

//新版的Hybrid解析
extension MLHybridTools {

    //init - ( 初始化 )
    func hybridInit(){
        guard let params:HybridInitParams = self.command.args.commandParams as? HybridInitParams  else {
            return
        }
        Hybrid_constantModel.hybridEvent = params.callback_name
        UserDefaults.standard.set(!params.cache, forKey: Hybrid_constantModel.switchCache)
    }
    //forward - (push 页面 )
    func hybridForward(){
        guard let params:HybridForwardParams = self.command.args.commandParams as? HybridForwardParams  else {
            return
        }
        if params.type == "h5" {
            guard let webViewController = MLHybrid.load(urlString: params.url) else {return}
            guard let navi = self.command.viewController.navigationController else {return}
            webViewController.title = params.title
            navi.pushViewController(webViewController, animated: params.animate)
        } else {
            //native跳转交给外部处理
            command.name = "forwardNative"
            MLHybrid.shared.delegate?.methodExtension(command: command)
        }
    }
    ////modal - (modal 页面)
    func hybridModal(){
        guard let params:HybridModalParams = self.command.args.commandParams as? HybridModalParams  else {
            return
        }
        if params.type == "h5" {
            guard let webViewController = MLHybrid.load(urlString: params.url) else {return}
            webViewController.title = params.title
            self.command.viewController.present(webViewController, animated: params.animate, completion: nil)
        } else {
            //native跳转交给外部处理
            command.name = "forwardModal"
            MLHybrid.shared.delegate?.methodExtension(command: command)
        }
    }
    //back - ( 返回上一页 )
    func hybridBack(){
        guard let params:HybridBackParams = self.command.args.commandParams as? HybridBackParams  else {
            return
        }
        guard let navigationVC = self.command.viewController.navigationController else {
            self.command.viewController.dismiss(animated: true, completion: nil)
            return
        }
        //-1代表跳入根目录
        if params.step == -1 {
            navigationVC.popToRootViewController(animated: true)
            return
        }
        //返回指定步骤
        if let vcs = self.command.viewController.navigationController?.viewControllers {
            if vcs.count > params.step {
                let vc = vcs[vcs.count - params.step - 1]
                let _ = self.command.viewController.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    //header - ( 导航栏 )
    func hybridHeader(){
        guard let params:HybridHeaderParams = self.command.args.commandParams as? HybridHeaderParams  else {
            return
        }
        guard let vc:MLHybridViewController = self.command.viewController else {
            return
        }
        self.command.viewController.title = params.title
        //设置导航栏是否显示
        vc.naviBarHidden = !params.show
        vc.navigationController?.setNavigationBarHidden(vc.naviBarHidden, animated: true)
        
        //设置背景色
        if params.background != "" {
            //根据16进制获取颜色值
            let backgroundColor:UIColor? = UIColor.colorWithHex(params.background)
            vc.navigationController?.navigationBar.isTranslucent = false
            vc.navigationController?.navigationBar.backgroundColor = backgroundColor
            vc.navigationController?.navigationBar.barTintColor = backgroundColor
            vc.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        }
        //设置左边按钮
        if params.left.count != 0 {
            let leftButtonItems:[UIBarButtonItem] = self.hybridHeaderBarButtonItems(params.left)
            self.command.viewController.navigationItem.setLeftBarButtonItems(leftButtonItems, animated: true)
        }
        //设置右边按钮
        if params.right.count != 0 {
            let rightButtonItems:[UIBarButtonItem] = self.hybridHeaderBarButtonItems(params.right)
            self.command.viewController.navigationItem.setLeftBarButtonItems(rightButtonItems, animated: true)
        }
    }
    //设置按钮
    func hybridHeaderBarButtonItems(_ buttonModels:[HybridHeaderParams.HybridHeaderButtonParams]) -> [UIBarButtonItem] {
        var barButtons:[UIBarButtonItem] = []
        for model:HybridHeaderParams.HybridHeaderButtonParams in buttonModels {
            let button:hybridHeaderButton = hybridHeaderButton.init()
            let titleWidth = model.title.hybridStringWidthWith(15, height: 20)
            let buttonWidth = titleWidth > 42 ? titleWidth : 42
            //这是大小
            button.frame = CGRect.init(x: 0, y: 0, width: buttonWidth, height: 44)
            //设置颜色
            let titleColor:UIColor = UIColor.colorWithHex(model.color)
            if titleColor != .clear {
                button.setTitleColor(UIColor.colorWithHex(model.color), for: .normal)
            }
            //设置图片
            if model.icon != ""{
                button.kf.setImage(with: URL(string: model.icon), for: .normal)
            }
            if model.title == "back" {
                let image = UIImage(named: MLHybrid.shared.backIndicator)
                button.setImage(image, for: .normal)
            }
            //设置标题
            if model.title.count > 0 {
                button.setTitle(model.title, for: .normal)
            }
            //添加点击事件
            button.buttonModel = model
            button.addTarget(self, action: #selector(hybridHeaderButtonClick(sender:)), for: .touchUpInside)
            //添加到数组
            barButtons.append(UIBarButtonItem.init(customView: button))
        }
        
        let spaceBar = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceBar.width = 1
        barButtons.insert(spaceBar, at: 0)
        return barButtons
    }
    //给UIButton添加数据
    class hybridHeaderButton: UIButton {
        var buttonModel:HybridHeaderParams.HybridHeaderButtonParams = HybridHeaderParams.HybridHeaderButtonParams()
    }
    @objc func hybridHeaderButtonClick(sender: hybridHeaderButton) {
        //默认是返回
        if sender.buttonModel.callback.count == 0 {
            self.command.viewController.navigationController?.popViewController(animated: true)
        }
        let _ = self.callBack(callback: sender.buttonModel.callback, webView: self.command.webView) { (str) in }
    }
    
    //scroll - ( 页面滚动 ,主要是回弹效果)
    func hybridScroll(){
        guard let params:HybridScrollParams = self.command.args.commandParams as? HybridScrollParams  else {
            return
        }
        self.command.webView.scrollView.bounces = params.enable
        let backgroundColor:UIColor = UIColor.colorWithHex(params.background)
        if backgroundColor != .clear {
            self.command.webView.scrollView.backgroundColor = backgroundColor
        }
    }
    //pageshow - ( 页面显示 )
    func hybridPageshow() {
        guard let params:HybridPageshowParams = self.command.args.commandParams as? HybridPageshowParams  else {
            return
        }
        _ = params
        self.command.viewController.onShowCallBack = self.command.callbackId
    }
    //pagehide - ( 页面隐藏 )
    func hybridPagehide() {
        guard let params:HybridPagehideParams = self.command.args.commandParams as? HybridPagehideParams  else {
            return
        }
        _ = params
        self.command.viewController.onHideCallBack = self.command.callbackId
    }
    //device - ( 获取设备信息 )
    func hybridDevice() {
        guard let params:HybridDeviceParams = self.command.args.commandParams as? HybridDeviceParams  else {
            return
        }
        _ = params
        let deviceInfor:[String:String] = ["version":Hybrid_constantModel.nativeVersion,
                                           "os":UIDevice.current.systemName,
                                           "dist":"app store",
                                           "uuid":UUID.init().uuidString]
        self.callBack(data: deviceInfor, err_no: 0, msg: "", callback: self.command.callbackId, webView:self.command.webView) { (result) in }
    }
    //location - ( 定位 )
    func hybridLocation(){
        guard let params:HybridLocationParams = self.command.args.commandParams as? HybridLocationParams  else {
            return
        }
        self.command.viewController.locationModel.getLocation { (success, errcode, resultData) in
            
            switch errcode {
            case 0:
                //定位成功
                _ = self.callBack(data: resultData as AnyObject? ?? "" as AnyObject, err_no: errcode, callback: params.located, webView: self.command.webView, completion: {js in })
            case 1:
                //无权限
                _ = self.callBack(data: resultData as AnyObject? ?? "" as AnyObject, err_no: 2, callback: params.failed, webView: self.command.webView, completion: {js in })
            case 2:
                //定位失败
                _ = self.callBack(data: resultData as AnyObject? ?? "" as AnyObject, err_no: 1, callback: params.failed, webView: self.command.webView, completion: {js in })
            default:
                break
            }
        }
    }
    //clipboard - ( 剪贴板 )
    func hybridClipboard(){
        guard let params:HybridClipboardParams = self.command.args.commandParams as? HybridClipboardParams  else {
            return
        }
        UIPasteboard.general.string = params.content
    }
}
