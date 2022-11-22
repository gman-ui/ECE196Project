//
//  ContentView.swift
//  Workout Buddy
//
//  Created by Kavi Nelakonda on 10/25/22.
//

import SwiftUI
import CoreBluetooth


struct FeedbackView: View {
    var choice: String
    @State var repCount: Int
    @State var repQuality: Double
    @State var feedback: String = ""
    @State var positive: Bool = true
    
    @Binding var isPresented: Bool
    
    //private let feedbackPos: [String] = ["Don't give up!",  "Almost there!", "Keep up the good work!", "You're great!", "Perfect!"]
    
    //private let feedbackNeg: [String] = [ "Just cancel your gym membership, save some money" , "Are you even trying?", "C'mon, this is terrible", "That's.... sufficient I guess....", "Up to par, whatever....", "Booooooo"]
    
    @EnvironmentObject var workout: WorkoutModel
    
    var body: some View {
        
        HStack {
            
            Spacer()
            VStack {

                Text(choice).font(.title).bold()
                VStack {
                    Spacer()

                    Text("💪🏽").font(.largeTitle).imageScale(.large)
                    Text("Rep number: **\(String(workout.repCount))**")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    
                    Text("Rep Quality: **\(String(format: "%.0f", workout.repQuality * 100))%**")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    Text(feedback)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                    Text("Push the button on the Watch to stop the workout!")
                    Spacer()
                }
                .background(.background)
                .onTapGesture {
                    workout.increaseRep()
                    if workout.feedbackP {
                        feedback = workout.randomChoiceP()
                    } else {
                        feedback = workout.randomChoiceN()
                    }
                }
            /*
              Text("Feedback Type").font(.title3).bold()
                HStack{
                    Spacer()
                    //not working as intended
                    Picker("", selection: $workout.feedbackP) {
                        Text("Positive")
                            .tag(true)
                        Text("Negative")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)

                }*/
                
                Button {
                    isPresented.toggle()
                } label: {
                    Text("Change Workout")
                        .font(.title2)
                        .bold()
                }
                
            }
            Spacer()
        }

    }
}

//struct FeedbackView_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedbackView(choice: "Chest Press", repCount: 1, repQuality: 1, positive: true, isPresented: true)
//    }
//}
