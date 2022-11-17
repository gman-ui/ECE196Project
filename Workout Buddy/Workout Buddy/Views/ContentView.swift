//
//  WorkoutView.swift
//  Workout Buddy
//
//  Created by Kavi Nelakonda on 10/27/22.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    //@State var exerciseChoice: String = "Chest Press"
    //private let locations: [String] = ["Wrist", "Bar"]
    //@State var wristLocation: Bool = true
    @State var isPresented: Bool = false
    //@State var feedbackP: Bool = true
    
    @StateObject var workout = WorkoutModel()
    
    var body: some View {
        if workout.loaded{
            VStack{
                Text("Workout Buddy").font(.largeTitle).bold()
                List{
                    HStack{
                        Text("Pick an exercise:").fontWeight(.bold)
                        Spacer()
                        Picker("", selection: $workout.exercise) {
                            ForEach(workout.exercises, id: \.self) { exercise in
                                Text(exercise).tag(exercise)
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack{
                        Text("Pick a location for the strap: ").fontWeight(.bold)
                        Spacer()
                        Picker("", selection: $workout.wristLocation){
                            Text("Wrist")
                                .tag(true)
                            Text("Bar")
                                .tag(false)
                        }.pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack{
                        Toggle(isOn: $workout.lightOn){
                            Text("Light On").fontWeight(.bold)
                        }
                        .onChange(of: workout.lightOn) { newValue in
                            workout.writeLight(value: newValue)
                            
                            guard !newValue else { return }
                            workout.peripheral?.readValue(for: workout.characteristics["x"]!)
                            print("x: \(workout.x)")
                            
                        }
                    }
                    
                }
                
                
                
                Button {
                    workout.repCount = 0
                    isPresented.toggle()
                } label: {
                    Text("Start The Workout!")
                        .font(.title2)
                        .bold()
                }
                .fullScreenCover(isPresented: $isPresented){
                    FeedbackView(choice: workout.exercise, repCount: workout.repCount, repQuality: 1, positive: workout.feedbackP, isPresented: $isPresented)
                        .environmentObject(workout)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    
                    VStack{
                        Text(workout.connected ? "Connected. Loading..." : "Looking for device...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

