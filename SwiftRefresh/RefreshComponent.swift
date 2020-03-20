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
    var hasShake = false
    private var _state = RefreshState.idle
    
    var state:RefreshState {
        get{
            return self._state
        }
        set{
            Log("state 设置新值 \(newValue)",String.init(format: "%p", self))
            if self._state == newValue{
                return
            }
            self._state = newValue
            Log("state 新值设置成功 \(self._state)")
            switch self._state {
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
                break
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
        if let closure = self.refreshClosure{
            closure()
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        Log("添加到父视图",String.init(format: "%p", self))
           if let scrollView = superview as? UIScrollView{
            scrollView.translatesAutoresizingMaskIntoConstraints = false
               self.scrollview = scrollView
               self.presenter.updateScrollView(scrollView)
               self.originContentOfSet = scrollView.re_inset.top
               NSLayoutConstraint.activate([
                   self.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                   self.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                   self.topAnchor.constraint(equalTo: scrollView.topAnchor),
                   self.heightAnchor.constraint(equalToConstant: 100)
               ])
               prepare()
           }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Log("初始化",String.init(format: "%p", self))
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        Log("进入 drawRect",String.init(format: "%p", self))
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
        Log("beginRefresh",String.init(format: "%p", self))
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
        Log("添加震动",String.init(format: "%p", self))
        if #available(iOS 10.0, *) {
            let feedback = UIImpactFeedbackGenerator.init(style: .light)
            feedback.prepare()
            feedback.impactOccurred()
        }
    }
    
    lazy var animationView: HeaderAnimation = {
        let view = HeaderAnimation.init(frame: self.bounds)
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
