//
//  Collections+Extension.swift
//  Tribes
//
//  Created by Kingsley Okeke on 2023-05-13.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
	public subscript(safe index: Index) -> Iterator.Element? {
		return (startIndex <= index && index < endIndex) ? self[index] : nil
	}
}
