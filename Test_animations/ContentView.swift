//
//  ContentView.swift
//  Test_animations
//
//  Created by kahalkar on 20/06/20.
//  Copyright © 2020 kahalkar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    //shape parameter
    @State var tapped = false
    @State var shapeRadius = 236.0
    @State var shapeSize = 100.0
    @State var shadowOffset = 7.0
    @State var shadowBlur = 10.0
    
    //color slider parameters
    @State private var isDragging: Bool = false
    @State private var startLocation: CGFloat = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var xOffset: CGFloat = .zero
    @State var chosenColor: Color  = Color(#colorLiteral(red: 0.5077621341, green: 0.05276752263, blue: 0, alpha: 1))
    private var linearGradientWidth: CGFloat = 300
    private var colors: [Color] = {
        let hueValues = Array(0...359)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 359.0 ,
                          saturation: 1.0,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }()
    var shapeStyle = ["Plain", "Concave", "Convex"]
    @State var pickerValue: Int = 0
    
    var body: some View {
        
        VStack {
            ZStack {
                self.chosenColor.edgesIgnoringSafeArea(.all)
                VStack(spacing: 5){
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: self.getGradientColor(for: self.pickerValue)),
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(self.chosenColor)
                        .frame(width: CGFloat(self.shapeSize), height: CGFloat(self.shapeSize))
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(self.shapeRadius)))
                        .padding(.top, 50)                            //top shadow
                        .shadow(color: self.currentColorLight.opacity(0.3),
                                radius: CGFloat(self.shadowBlur), x: -CGFloat(self.shadowOffset), y: -CGFloat(self.shadowOffset))
                        //bottopm shadow
                        .shadow(color: Color.black.opacity(0.3),
                                radius: CGFloat(self.shadowBlur), x: CGFloat(self.shadowOffset), y: CGFloat(self.shadowOffset))
                        .onTapGesture {
                            self.tapped.toggle()
                    }
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
                                        self.startLocation = value.startLocation.y
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
                            .offset(x: self.xOffset , y: self.isDragging ? -self.circleWidth() : 0.0)
                    }.frame(height: 40).animation(Animation.spring().speed(1))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).frame(height: 60).padding(8)
                            .foregroundColor(self.chosenColor)
                            .shadow(color:self.currentColorLight.opacity(0.3), radius: 5, x: -5, y: -5)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 5, y: 5)
                        
                        Picker(selection: self.$pickerValue, label: Text("Shape style picker")) {
                            Text(self.shapeStyle[0]).tag(0)
                            Text(self.shapeStyle[1]).tag(1)
                            Text(self.shapeStyle[2]).tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                    VStack(alignment: .leading) {
                        Text("Radius")
                        HStack {
                            Slider(value: self.$shapeRadius, in: 0...100, step: 1)
                            Text(String(self.shapeRadius))
                        }
                    }.padding()
                    VStack(alignment: .leading) {
                        Text("Size")
                        HStack {
                            Slider(value: self.$shapeSize, in: 10...200, step: 1)
                            Text(String(self.shapeSize))
                        }
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        Text("Shadow offset")
                        HStack {
                            Slider(value: self.$shadowOffset, in: 0...30, step: 1)
                            Text(String(self.shadowOffset))
                        }
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        Text("Shadow Blur")
                        HStack {
                            Slider(value: self.$shadowBlur, in: 0...50, step: 1)
                            Text(String(self.shadowBlur))
                        }
                    }.padding()
                }
            }
        }
    }
    
    /// 1
    /// Get the current color based on our current translation within the view
    private var currentColor: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 0.5, alpha: 1.0))
    }
    
    private var currentColorLight: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 1.0, alpha: 1.0))
    }
    
    /// 2
    /// Normalize our gesture to be between 0 and 200, where 200 is the height.
    /// At 0, the users finger is on top and at 200 the users finger is at the bottom
    private func normalizeGesture() -> CGFloat {
        let offset = startLocation + dragOffset.width // Using our starting point, see how far we've dragged +- from there
        let maxY = max(0, offset) // We want to always be greater than 0, even if their finger goes outside our view
        let minY = min(maxY, linearGradientWidth) // We want to always max at 200 even if the finger is outside the view.
        
        return minY
    }
    
    private func circleWidth() -> CGFloat {
        return isDragging ? 25 : 20
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
