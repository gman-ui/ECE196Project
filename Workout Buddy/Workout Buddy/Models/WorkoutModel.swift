//
//  WorkoutModel.swift
//  Workout Buddy
//
//  Created by Kavi Nelakonda on 11/8/22.
//

import Foundation
import SwiftUI
import CoreBluetooth



class WorkoutModel: ObservableObject{
    // CB objects
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    // marking something as @Published will make it update in the views
    @Published var repCount: Int = 0
    @Published var wristLocation: Bool = true
    @Published var feedbackP: Bool = true
    var repQuality: Double = 1
    @Published var feedback: String = ""
    
    @Published var exercise: String = "Chest Press"
    let exercises: [String] = ["Chest Press", "Squats", "Deadlifts", "Shoulder Press"]
    
    private let feedbackPos: [String] = ["Don't give up!",  "Almost there!", "Keep up the good work!", "You're great!", "Perfect!"]
    private let feedbackNeg: [String] = [ "Just cancel your gym membership, save some money" , "Are you even trying?", "C'mon, this is terrible", "That's.... sufficient I guess....", "Up to par, whatever....", "Booooooo"]
    
    
    func randomChoiceP() -> String{
        feedbackPos.randomElement()!
    }
    
    func randomChoiceN() -> String{
        feedbackNeg.randomElement()!
    }
    
    func increaseRep() -> Void{
        repCount += 1
    }
    
    func setExercise(e : String) -> Void{
        exercise = e
    }
    
}
