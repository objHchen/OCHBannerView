//
//  OCHBannerView.swift
//  OCHBannerView
//
//  Created by hchen on 2018/4/18.
//  Copyright © 2018年 QZW. All rights reserved.
//

import UIKit


/// BannerView 数据模型
struct OCHBannerViewData {
    let imageUrl: String?
    let imageLink: String?
    
    init(url: String, link: String) {
        self.imageUrl = url
        self.imageLink = link
    }
}

class OCHBannerView: UIView {
    
    /// 闭包回调
    typealias callbackBlock = (String) -> Void
    /// banner宽度
    private var _width:  CGFloat = 0
    /// banner高度
    private var _height: CGFloat = 0
    /// 定时器
    private var _timer: Timer?

    /// 滚动视图
    private var _scrollView:      UIScrollView?
    /// 分页显示
    private var _pageControl:     UIPageControl?
    /// 左边(上一张)图片
    private var _leftImageView:   UIImageView?
    /// 中间(当前)图片
    private var _centerImageView: UIImageView?
    /// 右边(下一张)图片
    private var _rightImageView:  UIImageView?
    
    /// 上一张图片下标
    private var _lastIndex:    NSInteger = 0
    /// 当前显示下标
    private var _currentIndex: NSInteger = 0
    /// 下一张图片下标
    private var _nextIndex:    NSInteger = 0
    
    /// 定时器间隔时间
    private var _timeInterval: CGFloat = 3.0
    
    /// 显示数据
    private var _dataSource:    [OCHBannerViewData]?
    
    /// 回调
    private var _bannerViewClick: callbackBlock?
    
    
    /// 过度，避免数据为空
    private var imagesData: [OCHBannerViewData] {
        set {
            _dataSource = newValue
            setupBannerScrollView()
            setupPageControl()
            setupImageViews()
            setupTimer()
        }
        get {
            return _dataSource!
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
    }
    
    /// 重写init方法
    ///
    /// - Parameters:
    ///   - width: banner width
    ///   - height: banner height
    ///   - dataSource: dataSource
    ///   - callback: callBack
    convenience init(width: CGFloat, height: CGFloat, dataSource: [OCHBannerViewData], callback: @escaping callbackBlock) {
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        _width = width
        _height = height
        imagesData = dataSource
        _bannerViewClick = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OCHBannerView {
    
    /// set scrollView
    private func setupBannerScrollView() {
        _scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: _width, height: _height))
        _scrollView?.bounces = false
        _scrollView?.delegate = self
        _scrollView?.isPagingEnabled = true
        _scrollView?.layer.masksToBounds = true
        _scrollView?.alwaysBounceVertical = false
        _scrollView?.alwaysBounceHorizontal = true
        _scrollView?.showsVerticalScrollIndicator = false
        _scrollView?.showsHorizontalScrollIndicator = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewClick))
        _scrollView?.addGestureRecognizer(tap)
        
        addSubview(_scrollView!)
        
    }
    
    /// set pageControl
    private func setupPageControl() {
        _pageControl?.removeFromSuperview()
        _pageControl = UIPageControl(frame: CGRect(x: 0, y: _height-20, width: _width, height: 20))
        _pageControl?.currentPage = _currentIndex
        _pageControl?.numberOfPages = (_dataSource?.count)!
        _pageControl?.pageIndicatorTintColor = UIColor.white
        _pageControl?.currentPageIndicatorTintColor = UIColor.red
        addSubview(_pageControl!)
    }
    
    /// set imageViews
    private func setupImageViews() {
        if _dataSource?.count == 1 {
            _scrollView?.contentSize = CGSize(width: 0, height: 0)
            _centerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: _width, height: _height))
            _centerImageView?.contentMode = .scaleToFill
            _scrollView?.addSubview(_centerImageView!)
            _centerImageView?.image = UIImage(named: _dataSource![_currentIndex].imageUrl!)
        } else {
            _scrollView?.contentSize = CGSize(width: _width * 3, height: 0)
            
            _lastIndex = (_dataSource?.count)!-1;    _currentIndex = 0;    _nextIndex = _currentIndex+1
            
            _leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: _width, height: _height))
            _leftImageView?.contentMode = .scaleToFill
            _scrollView?.addSubview(_leftImageView!)
            
            _centerImageView = UIImageView(frame: CGRect(x: _width, y: 0, width: _width, height: _height))
            _centerImageView?.contentMode = .scaleToFill
            _scrollView?.addSubview(_centerImageView!)
            
            _rightImageView = UIImageView(frame: CGRect(x: _width*2, y: 0, width: _width, height: _height))
            _rightImageView?.contentMode = .scaleToFill
            _scrollView?.addSubview(_rightImageView!)
            
            reloadData()
        }
    }
    
    /// set timer
    private func setupTimer() {
        if (_dataSource?.count)! > 1 {
            _timer = Timer.scheduledTimer(timeInterval: TimeInterval(_timeInterval), target: self,
                                          selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    
    /// 加载显示图片
    private func reloadData() {
        
        if _currentIndex == 0 {
            _lastIndex = (_dataSource?.count)! - 1
            _nextIndex = _currentIndex + 1
        } else if _currentIndex == (_dataSource?.count)! - 1 {
            _lastIndex = _currentIndex - 1
            _nextIndex = 0
        } else {
            _lastIndex = _currentIndex - 1
            _nextIndex = _currentIndex + 1
        }
        // MARK: - 加载数据源图片，更换网络图片加载方法
        
        // =======
        _leftImageView?.image = UIImage(named: _dataSource![_lastIndex].imageUrl!)
        _centerImageView?.image = UIImage(named: _dataSource![_currentIndex].imageUrl!)
        _rightImageView?.image = UIImage(named: _dataSource![_nextIndex].imageUrl!)
        // =======
        
        _scrollView?.setContentOffset(CGPoint(x: _width, y: 0), animated: false)
        _pageControl?.currentPage = _currentIndex
    }
    
    /// scrollView 手势事件-点击回调
    @objc func scrollViewClick() {
        if _bannerViewClick != nil {
            _bannerViewClick!(_dataSource![_currentIndex].imageLink!)
        }
    }
    
    /// 定时器事件
    @objc func timerAction() {
        _scrollView?.setContentOffset(CGPoint(x:_width * 2, y:0), animated: true)
    }
    
    /// 暂停定时器
    private func timerPause() {
        if (_timer != nil) {
            _timer?.fireDate = Date.distantFuture
        }
    }
    
    /// 启动定时器
    private func timerStart() {
        if (_timer != nil) {
            _timer?.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(_timeInterval)) as Date
        }
    }
}

extension OCHBannerView: UIScrollViewDelegate{
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        _currentIndex += 1
        if _currentIndex == _dataSource?.count {
            _currentIndex = 0
        }
        reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timerPause()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        
        if offset <= 0 {
            if _currentIndex-1 < 0 {
                _currentIndex = (_dataSource?.count)!-1
            } else {
                _currentIndex -= 1
            }
        }
        
        if offset >= _width*2 {
            if (_currentIndex == (_dataSource?.count)!-1) {
                _currentIndex = 0;
            }else{
                _currentIndex += 1
            }
        }
        
        reloadData()
        timerStart()
    }
    
}
