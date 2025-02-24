//
//  WordDefinitionMapper.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain

public class WordDefinitionMapper {
    public static func map(apiResponse: [WordDefinition]) -> WordDefinition? {
        return apiResponse.first
    }
}
