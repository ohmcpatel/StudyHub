//
//  ContentView.swift
//  StudyHub
//
//  Created by Ohm Patel  on 2/18/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("ContentView.WelcomeMessage".localized(arguments: "Caleb"))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
