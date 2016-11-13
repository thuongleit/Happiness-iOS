//
//  Question.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class Question: NSObject {
    
    var id: Int?
    var text: String?

}

class QuestionsList: NSObject {
    
    static var currentQuestionIndex = 0
    
    static let questions: [NSString] = [
        "What are you most grateful for today?",
        "Find out what your coworkers' favorite food/treat is. What are they?",
        "Who helped you out today?",
        "Go outside and immerse yourself in nature for at least 20 min. What did you see and hear?",
        "What did you do well today?",
        "Connect with someone new and find out their story. Write about it."
    ]

    class func getCurrentQuestion() -> Question {
        return getNextQuestion(0)
    }

    class func getNextQuestion(_ i: Int) -> Question {
        let question = Question()
        question.text = questions[currentQuestionIndex + i] as String
        return question
    }

    class func markCurrentQuestionCompleted() {
        currentQuestionIndex += 1
    }

}
