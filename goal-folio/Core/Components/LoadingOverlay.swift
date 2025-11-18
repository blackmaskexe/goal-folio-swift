//
//  LoadingOverlay.swift
//  goal-folio
//
//  Created by Pratham S on 11/12/25.
//

import SwiftUI

struct LoadingOverlay: View {
    @EnvironmentObject var loadingManager: LoadingManager
    
    var body: some View {
        if loadingManager.isLoading {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: loadingManager.isLoading)
        }
    }
}
