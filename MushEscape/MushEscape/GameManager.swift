//
//  GameManager.swift
//  MushEscape
//
//  Created by Daniele Perrupane on 11/12/23.
//

import Foundation

class GameManager {
    
    static let shared = GameManager() //Singleton
    
    private var startTime : Date?
    
    func startGame() {
        
        startTime = Date()
        
    }
    
    func endGame() -> TimeInterval?{
        
        guard let startTime = startTime else {
            return nil
        }
        
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        
        //Calcola il punteggio in base al tempo, per esempio +1 punto per ogni secondo
        let score = Int(elapsedTime)
        
        return TimeInterval(score)
    }
}
