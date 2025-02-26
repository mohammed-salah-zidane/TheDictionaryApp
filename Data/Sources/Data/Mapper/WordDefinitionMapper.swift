//
//  WordDefinitionMapper.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Domain

/// Utility class for mapping between API DTOs and domain models
public class WordDefinitionMapper {
    
    /// Maps an array of DTOs from the API to domain models
    /// - Parameter apiResponse: Array of WordDefinitionDTOs from the API
    /// - Returns: An array of domain WordDefinition models
    /// - Note: May return an empty array if mapping fails for all DTOs
    public static func mapToDomain(apiResponse: [WordDefinitionDTO]) -> [Domain.WordDefinition] {
        return apiResponse.compactMap { mapToDomain(dto: $0) }
    }
    
    /// Maps a single DTO to a domain model
    /// - Parameter dto: The WordDefinitionDTO to map
    /// - Returns: A domain WordDefinition model, or nil if mapping fails
    public static func mapToDomain(dto: WordDefinitionDTO) -> Domain.WordDefinition? {
        return Domain.WordDefinition(
            word: dto.word,
            phonetic: dto.phonetic,
            phonetics: dto.phonetics.map { mapPhoneticToDomain(dto: $0) },
            origin: dto.origin,
            meanings: dto.meanings.map { mapMeaningToDomain(dto: $0) }
        )
    }
    
    /// Maps a domain model to a DTO
    /// - Parameter domainModel: The domain WordDefinition to map
    /// - Returns: A WordDefinitionDTO
    public static func mapToDTO(domainModel: Domain.WordDefinition) -> WordDefinitionDTO {
        return WordDefinitionDTO(
            word: domainModel.word,
            phonetic: domainModel.phonetic,
            phonetics: domainModel.phonetics.map { mapPhoneticToDTO(domainModel: $0) },
            origin: domainModel.origin,
            meanings: domainModel.meanings.map { mapMeaningToDTO(domainModel: $0) }
        )
    }
    
    // MARK: - Private Helper Methods
    
    /// Maps a phonetic DTO to a domain phonetic
    private static func mapPhoneticToDomain(dto: PhoneticDTO) -> Domain.Phonetic {
        return Domain.Phonetic(
            text: dto.text,
            audio: dto.audio
        )
    }
    
    /// Maps a meaning DTO to a domain meaning
    private static func mapMeaningToDomain(dto: MeaningDTO) -> Domain.Meaning {
        return Domain.Meaning(
            partOfSpeech: dto.partOfSpeech,
            definitions: dto.definitions.map { mapDefinitionToDomain(dto: $0) }
        )
    }
    
    /// Maps a definition DTO to a domain definition
    private static func mapDefinitionToDomain(dto: DefinitionDTO) -> Domain.Definition {
        return Domain.Definition(
            definition: dto.definition,
            example: dto.example,
            synonyms: dto.synonyms,
            antonyms: dto.antonyms
        )
    }
    
    /// Maps a domain phonetic to a DTO phonetic
    private static func mapPhoneticToDTO(domainModel: Domain.Phonetic) -> PhoneticDTO {
        return PhoneticDTO(
            text: domainModel.text,
            audio: domainModel.audio
        )
    }
    
    /// Maps a domain meaning to a DTO meaning
    private static func mapMeaningToDTO(domainModel: Domain.Meaning) -> MeaningDTO {
        return MeaningDTO(
            partOfSpeech: domainModel.partOfSpeech,
            definitions: domainModel.definitions.map { mapDefinitionToDTO(domainModel: $0) }
        )
    }
    
    /// Maps a domain definition to a DTO definition
    private static func mapDefinitionToDTO(domainModel: Domain.Definition) -> DefinitionDTO {
        return DefinitionDTO(
            definition: domainModel.definition,
            example: domainModel.example,
            synonyms: domainModel.synonyms,
            antonyms: domainModel.antonyms
        )
    }
    
    /// Maps the first available WordDefinition from the array
    /// - Parameter apiResponse: Array of domain WordDefinition models
    /// - Returns: The first available WordDefinition, or nil if the array is empty
    public static func map(apiResponse: [Domain.WordDefinition]) -> Domain.WordDefinition? {
        return apiResponse.first
    }
}
