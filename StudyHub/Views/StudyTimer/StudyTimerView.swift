//
//  StudyTimerView.swift
//  StudyTimer
//
//  Created by Caleb Atchison on 4/15/24.
//

import Foundation
import SwiftUI

struct StudyTimerView: View {
    
    @StateObject private var vm = StudyTimerViewModel()
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private let width: Double = 250
        
        var body: some View {
            VStack {
                Text("\(vm.time)")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .alert("Studying complete!", isPresented: $vm.showingAlert) {
                        Button("Continue", role: .cancel) {
                            // Code
                        }
                    }
                    .padding()
                    .frame(width: width)
                    .background(.thickMaterial)
                    .cornerRadius(25)
                    .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: 0xFA4A0C, opacity: 1), lineWidth: 7)
                        )
                
                Slider(value: $vm.minutes, in: 1...60, step: 1)
                    .padding()
                    .disabled(vm.isActive)
                    .animation(.easeInOut, value: vm.minutes)
                    .frame(width: width)
                    .accentColor(Color(hex: 0xFA4A0C, opacity: 1))

                HStack(spacing:50) {
                    Button("Start") {
                        vm.start(minutes: vm.minutes)
                    }
                    .disabled(vm.isActive)
                    
                    Button("Reset", action: vm.reset)
                        .tint(.red)
                }
                .frame(width: width)
            }
            .onReceive(timer) { _ in
                vm.updateCountdown()
            }
            
        }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        StudyTimerView()
    }
}
