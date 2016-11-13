//
//  Question.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class Question: NSObject {
    
    var id: String?
    var text: String?
    
    // For creating a Question from the server data
    init(questionObject: AnyObject) {
        if let id = questionObject.object(forKey: "objectId") as? String {
            self.id = id
        }
        if let text = questionObject.object(forKey: "text") as? String {
            self.text = text
        }
    }
    
    // For creating a Question on the client side
    init(text: String?) {
        if let text = text {
            self.text = text
        }
    }
}

class QuestionsList: NSObject {
    
    static var currentQuestionIndex = 0
    
    static let questions: [String] = [
        "What are you most grateful for today?",
        "Find out what your coworkers' favorite food/treat is. What are they?",
        "Who helped you out today? What did you appreciate or admire?",
        "Go outside and immerse yourself in nature for at least 20 min. What did you see and hear?",
        "What did you do well today?",
        "Connect with someone new and find out their story. Write about it."
    ]
    
    // Returns the current question that the user hasn't answered recently yet.
    class func getCurrentQuestion() -> Question {
        return getNextQuestion(0)
    }
    
    // Returns the next nth question for displaying only. getCurrentQuestion() will continue returning
    // the same question until markCurrentQuestionCompleted() is called.
    class func getNextQuestion(_ i: Int) -> Question {
        let questionString = questions[currentQuestionIndex + i]
        let question = Question(text: questionString)
        return question
    }
    
    // Marks current question as answered so we don't ask it immediately again. Should be called
    // when user creates an entry for the current question.
    class func markCurrentQuestionCompleted() {
        currentQuestionIndex += 1
    }
    
}
