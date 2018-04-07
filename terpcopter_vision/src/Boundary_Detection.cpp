#include "opencv2/opencv.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
 

using namespace std;
using namespace cv;

Mat frame, gray, edges, imgHSV, imgThreshold, contours, black_edges;

//Edge Detection Parameters
int lowThreshold = 0;
int ratio = 3;
int kernel_size = 3;

//Dilation parameter
int dilation_size = 3;

//Boundary Detection parameters
vector<Vec2f> lines;
double theta;

//Text parameters to be written on the frame
string text1 = "Boundary Detected, Roll right";
string text2 = "ALERT! Nearing Boundary. Roll Right Immediately.";
string text3 = "Boundary Detected, Roll left";
string text4 = "ALERT! Nearing Boundary. Roll Left Immediately.";
string text5 = "Pitch Backward";
int fontFace = CV_FONT_HERSHEY_PLAIN;
double fontScale = 2;
int thickness = 3;
int baseline=0;


int main(){

  VideoCapture cap(0); 
  if(!cap.isOpened()){
    cout << "Error opening video stream or file" << endl;
    return -1;
  }

  vector<Point2f> prev_point(1);
  prev_point[0].x = 0;
  prev_point[0].y = 0;  

  while(1){
 
    Mat frame;
    cap >> frame;
    if (frame.empty())
      break;

  //Defining text writing
  Size textSize = getTextSize(text1, fontFace,
                            fontScale, thickness, &baseline);
  baseline += thickness;
  Point textOrg((frame.cols - textSize.width)/2,(frame.rows + textSize.height)/2);
  

  //Edge detection starts here
  cvtColor(frame, gray, CV_BGR2GRAY );  
  cvtColor(frame,imgHSV,CV_BGR2HSV);

  //Thresholding for yellow
  cv::inRange(imgHSV, cv::Scalar(14,135,139,0), cv::Scalar(30,1.00*256,1.00*256,0), imgThreshold);
  bitwise_and(gray,imgThreshold,gray);
  blur(gray,edges, Size(3,3));
  Canny(edges,edges,lowThreshold,lowThreshold*ratio,kernel_size );
  
  //Dilation for better contour detection
  int dilation_type = MORPH_RECT;
  Mat element = getStructuringElement( dilation_type,
                                       Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                       Point( dilation_size, dilation_size ) );
  dilate(edges, edges, element );
  
  //Contour Detection
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  findContours(edges, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );

  Mat black(edges.rows,edges.cols, CV_8UC3, Scalar(0,0,0));
  vector<Moments> mu(contours.size());
  vector<Point2f> mc(contours.size());
  vector<vector<Point> > contours_poly( contours.size() );
  vector<Rect> boundRect( contours.size() );
    
  // Drawing contours
  for( int i = 0; i < contours.size(); i++ )
     { 

      approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
      boundRect[i] = boundingRect( Mat(contours_poly[i]) );
       
      double height = boundRect[i].height;
      double width = boundRect[i].width;
      double area = contourArea(contours[i]);
      //cout<<area<<"\t"<< height<<"\t"<<width<<endl;
      
      if (area > 100 && height<500 && width<500 && height >5 && width>5)
      {
      drawContours(black, contours, i, Scalar(255,255,255), 2, 8, hierarchy, 0, Point() );
      mu[i] = moments( contours[i], false); //c = max(cnts, key=cv2.contourArea)
      mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
      
      //Drawing centroid for black contours
      circle(black, mc[i], 4, Scalar(0,0,255), -1, 8, 0 );
      //cout<<mc[i].x<<endl;
      line(black,mc[i],prev_point[0],Scalar(255,0,0),2, CV_AA);
      prev_point[0].x = mc[i].x;
      prev_point[0].y = mc[i].y;
      Canny(black, black_edges,lowThreshold,lowThreshold*ratio,kernel_size );
      HoughLines(black_edges, lines, 1, CV_PI/180, 75, 0, 0 );

      for( size_t j = 0; j < lines.size(); j++ )
    {  theta = lines[j][1];
      cout<<tan(theta)<<endl;

    }
      if(mc[i].x > 0 && mc[i].x<200 && tan(theta)<=0.2 && tan(theta)>=-0.2)
        //cout<<"Boundary Detected, Roll right"<<endl;
        putText(frame, text1, textOrg, fontFace, fontScale,
        Scalar::all(255), thickness, 8);
      if(mc[i].x > 220 && mc[i].x<320 && tan(theta)<=0.2 && tan(theta)>=-0.2)
        //cout<<"ALERT! Nearing Boundary. Roll Right Immediately."<<endl;
        putText(frame, text2, textOrg, fontFace, fontScale,
        Scalar::all(255), thickness, 8);
      if(mc[i].x < 640 && mc[i].x > 480 && tan(theta)<=0.2 && tan(theta)>=-0.2)
        //cout<<"Boundary Detected, Roll left"<<endl;
        putText(frame, text3, textOrg, fontFace, fontScale,
        Scalar::all(255), thickness, 8);
      if(mc[i].x > 380 && mc[i].x< 480 && tan(theta)<=0.2 && tan(theta)>=-0.2)
        //cout<<"ALERT! Nearing Boundary. Roll Left Immediately."<<endl;
        putText(frame, text4, textOrg, fontFace, fontScale,
        Scalar::all(255), thickness, 8);
      if (tan(theta)>3 || tan(theta)<-10)
        putText(frame, text5, textOrg, fontFace, fontScale,
        Scalar::all(255), thickness, 8);
      //cout<<;
      }
    }
  //cout<<edges.rows<<"\t"<<edges.cols<<endl;  
  imshow( "Frame", frame );
  imshow("edges",edges);
  imshow("Black",black); 
    // Press  ESC on keyboard to exit
    char c=(char)waitKey(25);
    if(c==27)
      break;
  }
  
  // When everything done, release the video capture object
  cap.release();
 
  // Closes all the frames
  destroyAllWindows();
     
  return 0;
}