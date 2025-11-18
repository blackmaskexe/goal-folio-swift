//
//  LoadingManager.swift
//  goal-folio
//
//  Created by Pratham S on 11/12/25.
//

import SwiftUI
import Combine

final class LoadingManager: ObservableObject {
    @Published var isLoading: Bool = false
    
  
    // Convenient helper functions
    func show() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLoading = true
        }
    }
    
    func hide() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLoading = false
        }
    }
}
