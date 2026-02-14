//
//  BeautyRoutine.swift
//  SkinGlowing
//
//  Beauty routine model and related types
//

import Foundation
import SwiftUI

struct BeautyRoutine: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: String
    let steps: Int
    let icon: String
    let description: String
    let difficulty: String
    let products: [String]

    init(id: UUID = UUID(), name: String, duration: String, steps: Int, icon: String, description: String, difficulty: String, products: [String]) {
        self.id = id
        self.name = name
        self.duration = duration
        self.steps = steps
        self.icon = icon
        self.description = description
        self.difficulty = difficulty
        self.products = products
    }
}

struct BeautyRoutineStep: Identifiable, Codable {
    let id: UUID
    let stepNumber: Int
    let title: String
    let description: String
    let duration: Int // in seconds
    let instructions: [String]
    let productType: String?

    init(id: UUID = UUID(), stepNumber: Int, title: String, description: String, duration: Int, instructions: [String], productType: String? = nil) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.duration = duration
        self.instructions = instructions
        self.productType = productType
    }
}