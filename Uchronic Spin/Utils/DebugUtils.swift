//
//  DebugUtils.swift
//  Uchronic Spin
//
//  Created by Ettore Pasquini on 10/1/25.
//

func pointer(_ obj: AnyObject) -> UnsafeMutableRawPointer {
    Unmanaged.passUnretained(obj).toOpaque()
}
