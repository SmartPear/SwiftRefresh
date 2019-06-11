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
    private var _state:RefreshState = .idle
    weak var scrollview:UIScrollView?
    var originContentOfSet = CGPoint.zero
    var dragProgress:CGFloat = 0.0
    var hasShake = false

    
    var state:RefreshState {
        get{
            return _state
        }
        set{
            if _state == newValue{
                return
            }
            _state = newValue
            switch newValue {
            case .idle:
                self.dragProgress = 0
                hasShake = false
                showNoMoreDataView(false)
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
                self.dragProgress = 0
                self.hasShake = false
                refreshComplete(false)
            case .noMoreData:
                self.dragProgress = 0
                showNoMoreDataView(true)
            }
        }
    }
    
    func showNoMoreDataView(_ show:Bool) {
        self.animationView.isHidden = show
        self.noMoredataView.isHidden = !show
        self.isHidden = false
    }
    
    
    
    func executeRefreshingCallback() {
        if let closure = self.refreshClosure{
            closure()
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView{
            self.scrollview = scrollView
            self.presenter.updateScrollView(scrollView)
            prepare()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.autoresizingMask = .flexibleWidth
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func prepare()  {
        
    }
    
    func startRefresh() {
        
    }
    
    func refreshComplete(_ noMore:Bool) {
        
    }
    
    func gesStateChanged(_ state:UIGestureRecognizer.State) {
        if state == .ended{
            if self.state == .willRefresh{
                self.state = .refreshing
            }
        }
    }
    
    ///添加震动
    func addShake()  {
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
    
    func dragEnd() {
        
    }
    
    func initContentOffset(_ ofset: CGPoint) {
        self.originContentOfSet = ofset
    }
    
    @objc func scrollViewContentOffsetDidChange(_ change:CGPoint) {
        
    }
    
    @objc func scrollViewContentSizeDidChange(_ size:CGSize) {
        
    }
}
