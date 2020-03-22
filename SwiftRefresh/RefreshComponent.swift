//
//  RefreshComponent.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit



public class RefreshComponent: UIView {
    
    var refreshClosure:(()->Void)?
    weak var scrollview:UIScrollView?
    var originContentOfSet:CGFloat = 0.0
    var topConstraint:NSLayoutConstraint?
    var heightConstraint:NSLayoutConstraint?
    
    var hasShake = false    
    var state:RefreshState = .idle{
        willSet{
            if self.state == newValue {
                return
            }
        }
        
        didSet{
            switch self.state {
                case .idle:
                    hasShake = false
                    showNoMoreDataView(false)
                case .pulling:
                    break
                case .refreshing:
                    self.hasShake = true
                    startRefresh()
                case .willRefresh:
                    if  hasShake == false{
                        hasShake = true
                        addShake()
                }
                case .end:
                    self.hasShake = false
                    refreshComplete(false)
                case .noMoreData:
                    showNoMoreDataView(true)
            }
        }
    }
    
    
    func showNoMoreDataView(_ show:Bool) {
        self.animationView.isHidden = show
        self.noMoredataView.isHidden = !show
    }
    
    func executeRefreshingCallback() {
        refreshClosure?()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scrollView = superview as? UIScrollView{
            self.scrollview = scrollView
            self.presenter.updateScrollView(scrollView)
            self.originContentOfSet = scrollView.re_inset.top
            topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
            heightConstraint =  NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5)
            NSLayoutConstraint.activate([
                topConstraint!,heightConstraint!,
                NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            ])
            setNeedsDisplay()
        }
    }
    
    public override func removeFromSuperview() {
        self.presenter.removeObservers()
        self.scrollview = nil
        super.removeFromSuperview()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        prepare()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        if self.state == .willRefresh{
            Log("willRefresh 进入刷新")
            if let scroll = self.scrollview{
                self.originContentOfSet = scroll.re_insetTop
            }
            self.state = .refreshing
        }else{
            Log("drawRect 不刷新")
        }
    }
    
    
    func prepare()  {
        
    }
    
    @objc public func beginRefresh(){
        if self.isHidden {
            return
        }
        if self.state != .refreshing{
            if self.window != nil{
                self.state = .refreshing
            }else{
                self.state = .willRefresh
            }
        }
    }
    
    @objc public func endRefresh() {
        if self.state == .refreshing{
            self.state = .end
        }
    }
    
    func safeThread(_ funcRun:@escaping (()->Void)) {
        if Thread.current.isMainThread {
            funcRun()
        }else{
            DispatchQueue.main.async {
                funcRun()
            }
        }
    }
    
    func startRefresh() {
    }
    
    func refreshComplete(_ noMore:Bool) {
    }
    
    func gesStateChanged(_ gesState:UIGestureRecognizer.State) {
        if gesState == .ended{
            if self.state == .willRefresh{
                self.state = .refreshing
            }
        }
    }
    
    ///添加震动
    func addShake()  {
        let feedback = UIImpactFeedbackGenerator.init(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    lazy var animationView: HeaderAnimation = {
        let view = HeaderAnimation.init()
        return view
    }()
    
    lazy var noMoredataView: NoMoreDataView = {
        let view = NoMoreDataView.init(frame: self.bounds)
        view.setNoData(with: noMoreDataText)
        view.isHidden = true
        return view
    }()
    
    lazy var presenter: RefreshCommon = {
        let comm = RefreshCommon.init(viewTool: self)
        return comm
    }()
    
}

extension RefreshComponent:RefreshProtocol{
    
    func dragEnd() {}
    
    func initContentOffset(_ ofset: CGPoint) {}
    
    @objc func scrollViewContentOffsetDidChange(_ change:CGPoint) {}
    
    @objc func scrollViewContentSizeDidChange(_ size:CGSize) {}
}
