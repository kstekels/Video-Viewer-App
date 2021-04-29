## iOS Developer Test Assignment

### Task

Create an application from scratch where users can pick a video from a list and watch it in the details view. Also they have to be able to download and watch the video when there's no internet connection.

Please make sure you are following all guidelines before submitting your solution.

### Requirements

Video list screen:
- Display title “_Videos_”;
- Display a list of videos;
- Display a thumbnail image and name for each video;
- Implemented pull-to-refresh functionality to refresh the list of videos;
- List of videos has to be fetched, from URL or cache, on application launch.

Video details screen:
- Display video player;
- Display a “_Download video_” button to start download for offline viewing;
- Display a “_Cancel download_” and progress bar when video is downloading;
- Display video title and description.

API endpoint: `https://iphonephotographyschool.com/test-api/videos`.

### Design

Design has to closely match the following screenshots and look good in both, light and dark modes.

<img alt="Video list screenshot" src="video_list_screen.png" width="50%" /><img alt="Video details screenshot" src="video_details_screen.png" width="50%" />

### What we are looking for:

- Develop the application using:
  - Xcode;
  - CocoaPods;
  - SwiftUI;
  - Combine.
- Try to use as few 3<sup>rd</sup>-party libraries as possible. It's fine to use CocoaPods for pull-to-refresh and Alamofire;
- Application has to work offline with cached video list;
- Write automated tests using framework of your choice. Tests have to be meaningful and comprehensive and cover all important functionality of the application. 

### Submission

Project should be stored in your own GitHub repository. Repository should contain commits representing different stages of progress.

Make sure that all tests pass before submitting.

## Result
![ezgif com-gif-maker](https://user-images.githubusercontent.com/31929901/116623269-aa061280-a94e-11eb-8265-6a45335d393a.gif)
![ezgif com-gif-maker(1)](https://user-images.githubusercontent.com/31929901/116623297-b68a6b00-a94e-11eb-9c5e-27c76dc048d0.gif)
![ezgif com-gif-maker(2)](https://user-images.githubusercontent.com/31929901/116623326-c1450000-a94e-11eb-8c01-5e615f2fd9f7.gif)
![ezgif com-gif-maker(3)](https://user-images.githubusercontent.com/31929901/116623341-c6a24a80-a94e-11eb-98cf-410a1b343ad0.gif)
![ezgif com-gif-maker(4)](https://user-images.githubusercontent.com/31929901/116623353-ca35d180-a94e-11eb-9512-92fd2df8652b.gif)
