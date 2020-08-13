//
//  ContentView.swift
//  Test_animations
//
//  Created by kahalkar on 20/06/20.
//  Copyright © 2020 kahalkar. All rights reserved.
//

import SwiftUI

struct SliderView: View {
    var title: String
    @Binding var sliderValue: CGFloat
    var minRange: CGFloat
    var maxRange: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                Slider(value: $sliderValue, in: minRange...maxRange, step: 1)
                Text(String(Int(sliderValue))) // do I really need to do this?
            }
        }.padding()
    }
}

struct ContentView: View {
    //shape parameter
    @State var tapped = false
    @State var shapeRadius: CGFloat = 0.0
    @State var shapeSize: CGFloat = 100.0
    @State var shadowOffset: CGFloat = 7.0
    @State var shadowBlur: CGFloat = 10.0
    
    //color slider parameters
    @State private var isDragging: Bool = false
    @State private var startLocation: CGFloat = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var xOffset: CGFloat = .zero
    @State var chosenColor: Color  = Color(#colorLiteral(red: 0.5077621341, green: 0.05276752263, blue: 0, alpha: 1))
    @State var pickerValue: Int = 0
    
    private var linearGradientWidth: CGFloat = 300
    private var colors: [Color] = {
        let hueValues = Array(0...255)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 255.0 ,
                          saturation: 1.0,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }()
    private let shapeStyle = ["Plain", "Concave", "Convex"]
    
    
    var body: some View {
        
        VStack {
            ZStack {
                self.chosenColor.edgesIgnoringSafeArea(.all)
                VStack(spacing: 5){
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: self.getGradientColor(for: self.pickerValue)),
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                        .foregroundColor(self.chosenColor)
                        .frame(width: CGFloat(self.shapeSize), height: CGFloat(self.shapeSize))
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(self.shapeRadius)))
                        .padding(.top, 50)
                        //top shadow
                        .shadow(color: self.currentColorLight.opacity(0.3),
                                radius: CGFloat(self.shadowBlur), x: -self.getShadowOffset(value: shadowOffset), y: -self.getShadowOffset(value: shadowOffset))
                        //bottopm shadow
                        .shadow(color: Color.black.opacity(0.3),
                                radius: CGFloat(self.shadowBlur), x: self.getShadowOffset(value: shadowOffset), y: self.getShadowOffset(value: shadowOffset))
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            self.tapped.toggle()
                    }.animation(.easeInOut)
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle().fill(LinearGradient(gradient: Gradient(colors: self.colors),
                                                        startPoint: .leading, endPoint: .trailing))
                            .frame(width: self.linearGradientWidth, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .gesture(
                                DragGesture()
                                    .onChanged({ (value) in
                                        self.dragOffset = value.translation
                                        self.xOffset = value.location.x
                                        self.startLocation = value.startLocation.x
                                        self.chosenColor = self.currentColor
                                        self.isDragging = true
                                    }).onEnded({ (_) in
                                        self.isDragging = false
                                    })
                        )
                        Circle()
                            .frame(width: self.circleWidth())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .foregroundColor(self.chosenColor)
                            .offset(x: self.normalizedX() , y: self.isDragging ? -self.circleWidth() : 0.0).animation(.easeInOut)
                    }.frame(height: 40)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).frame(height: 60).padding(8)
                            .foregroundColor(self.chosenColor)
                            .shadow(color:self.currentColorLight.opacity(0.3), radius: 3, x: -3, y: -3)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                        
                        Picker(selection: self.$pickerValue, label: Text("Shape style picker")) {
                            Text(self.shapeStyle[0]).tag(0)
                            Text(self.shapeStyle[1]).tag(1)
                            Text(self.shapeStyle[2]).tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                    
                    SliderView(title: "Radius", sliderValue: $shapeRadius, minRange: 0, maxRange: 100)
                    SliderView(title: "Size", sliderValue: $shapeSize, minRange: 10, maxRange: 200)
                    SliderView(title: "Shadow offset", sliderValue: $shadowOffset, minRange: 0, maxRange: 30)
                    SliderView(title: "Shadow Blur", sliderValue: $shadowBlur, minRange: 0, maxRange: 50)
                }
            }
        }
    }
    
    private func getShadowOffset(value: CGFloat) -> CGFloat {
        self.tapped ? -value : value
    }
    /// Get the current color based on our current translation within the view
    private var currentColor: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 0.7, alpha: 1.0))
    }
    
    private var currentColorLight: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 1.0, alpha: 1.0))
    }
    
    ///
    private func normalizeGesture() -> CGFloat {
        let offset = startLocation + dragOffset.width // Using our starting point, see how far we've dragged +- from there
        // We want to always be greater than 0, even if their finger goes outside our view
        // We want to always max at 200 even if the finger is outside the view.
        return min(max(0, offset), linearGradientWidth)
        
        
    }
    
    private func normalizedX() -> CGFloat {
         return min(max(0, self.xOffset), linearGradientWidth - circleWidth())
    }
    
    private func circleWidth() -> CGFloat {
        return isDragging ? 25 : 0
    }
    
    private func getGradientColor(for pickerValue: Int) -> [Color] {
        switch pickerValue {
        case 0:
            return [currentColor, currentColor]
        case 1:
            return [self.currentColorLight.opacity(0.3), Color.black.opacity(0.3)]
        default:
            return [Color.black.opacity(0.3), self.currentColorLight.opacity(0.3)]
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
