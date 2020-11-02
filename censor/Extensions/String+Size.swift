//
//  String+Size.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import UIKit

extension String {
    func height(width: CGFloat, attributes: [NSAttributedString.Key: Any]?) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(height: CGFloat, attributes: [NSAttributedString.Key: Any]?) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    func height(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(boundingBox.height)
    }

    func width(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(boundingBox.width)
    }
}

