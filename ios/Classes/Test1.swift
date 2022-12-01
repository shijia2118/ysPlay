//
//  Test1.swift
//  ys_play
//
//  Created by qingxiuHan on 2022/11/30.
//

import Foundation

class ClassA {
    var a0: Int = 1
    var a1: String = "ss"
    
    init(){}
    
    init(a0: Int,a1:String) {
        self.a0 = a0
        self.a1 = a1
        
    }
    
    
    
    
}

class ClassB: ClassA {
   
    
    let a = ClassA(a0: 10, a1: "10")
    let b = ClassA()
}


