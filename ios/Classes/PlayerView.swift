//
//  PlayerView.swift
//  ys_play
//
//  Created by qingxiuHan on 2022/11/30.
//

import Foundation

class PlayerView: NSObject, FlutterPlatformView {
    
    private var _view: UIView
    
    init(
        _view: UIView,
        viewIdentifier viewId: Int64) {
        self._view = _view
    }
    
    func view() -> UIView {
        return _view;
    }
    
    
}
