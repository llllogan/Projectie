//
//  Debouncer.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 21/1/2025.
//

import Foundation

class TransactionNoteAutoSaveTimer {
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let interval: TimeInterval

    
    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }

    
    func call(action: @escaping () -> Void) {
        workItem?.cancel()
        
        workItem = DispatchWorkItem(block: action)
        
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + interval, execute: workItem)
        }
    }
}
