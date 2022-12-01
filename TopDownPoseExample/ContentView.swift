import SwiftUI

struct ContentView: View {
  @StateObject var pose = Pose()
  var body: some View {
    VStack {
      if (pose.uiImage != nil){
        Image(uiImage: pose.uiImage!).resizable()
          .aspectRatio(contentMode: .fit)
      }
    }
    .onAppear {
      Task {
        await test()
      }
    }
    .padding()
  }
  func test() async {
    pose.setupVision()
    let imgPath = "test.jpg"
    let img = UIImage(named: imgPath)!
    await pose.prediction(imageBuffer: img)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
