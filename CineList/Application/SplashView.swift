import SwiftUI

struct SplashView: View {
    let splashBackgroundColor = Color(red: 232/255, green: 90/255, blue: 79/255)
    let textColor = Color.white

    var body: some View {
        ZStack {
            splashBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                Image("SplashScreen") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                Text("CineList")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
                
                Text("Your Screen, Curated.")
                    .font(.title)
                    .foregroundColor(textColor.opacity(0.8))
                
                Spacer()
                Spacer()
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    SplashView()
} 
