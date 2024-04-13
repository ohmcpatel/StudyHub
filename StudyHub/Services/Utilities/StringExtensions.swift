//
//  StringExtensions.swift
//  StudyHub
//
//  Created by Ohm Patel  on 2/18/24.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    func localized(arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
