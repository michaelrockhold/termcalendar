//
//  ResultBuilderTemplate.swift
//  termcalendar
//
//  Created by Michael Rockhold on 1/17/22.
//

import Foundation

@resultBuilder
struct FooBuilder {
    typealias Component = [Foo]
    typealias Expression = Bar

    // Combines an array of partial results into a single partial result. A result builder must implement this method.
    static func buildBlock(_ components: Component...) -> Component

    // Builds a partial result from a partial result that can be nil. Implement this method to support if statements that don’t include an else clause.
    static func buildOptional(_ component: Component?) -> Component

    // Builds a partial result whose value varies depending on some condition. Implement both this method and buildEither(second:) to support switch statements and if statements that include an else clause.
    static func buildEither(first: Component) -> Component
    
    // Builds a partial result whose value varies depending on some condition. Implement both this method and buildEither(first:) to support switch statements and if statements that include an else clause.
    static func buildEither(second: Component) -> Component

    // Builds a partial result from an array of partial results. Implement this method to support for loops.
    static func buildArray(_ components: [Component]) -> Component
    
    // Builds a partial result from an expression. You can implement this method to perform preprocessing—for example, converting expressions to an internal type—or to provide additional information for type inference at use sites.
    static func buildExpression(_ expression: Expression) -> Component

    // Builds a final result from a partial result. You can implement this method as part of a result builder that uses a different type for partial and final results, or to perform other postprocessing on a result before returning it.
    static func buildFinalResult(_ component: Component) -> FinalResult
    
    static func buildLimitedAvailability(_ component: Component) -> Component
}
