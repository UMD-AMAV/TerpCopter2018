/*Things to do:
1. Publish the centroid data
2. Make line detection more robust    
*/

#include "opencv2/opencv.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
 
using namespace std;
using namespace cv;

Mat frame,gray,edges,contours, black_edges;
Mat imgThreshold, imgHSV;

//Edge Detection Parameters
int lowThreshold = 0;
int ratio = 3;
int kernel_size = 3;

//Dilation Parameter
int dilation_type = MORPH_RECT;
int dilation_size = 3;

//Line Detection parameters
vector<Vec2f> lines;

double maxArea = 10000.0; //This has to be calibrated

double theta_prev;

// Add a function to detect squares
void CannyEdge(Mat frame)
{	
	//Color Thresholding
	cvtColor(frame,imgHSV,CV_BGR2HSV);
	cv::inRange(imgHSV, cv::Scalar(0, 0, 0, 0), cv::Scalar(180, 255, 30, 0), imgThreshold);
	bitwise_and(gray,imgThreshold,gray);
	blur(gray,gray, Size(3,3));

	//Detecting Edges
	Canny(gray,edges,lowThreshold,lowThreshold*ratio,kernel_size);
	
	
	//Dilation for better contour detection
	Mat element = getStructuringElement( dilation_type,
                                       Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                       Point( dilation_size, dilation_size ) );
  	dilate(edges, edges, element );
	

  	//Detecting Contours
  	vector<vector<Point> > contours;
	vector<Vec4i> hierarchy;
	findContours(edges, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
	Mat black(edges.rows,edges.cols, CV_8UC3, Scalar(0,0,0));
	
    vector<Moments> mu(contours.size());
    vector<Point2f> mc(contours.size());
    vector<vector<Point> > contours_poly( contours.size() );
    vector<Rect> boundRect( contours.size() );
    
    //Drawing contours based on certain conditions
 	for( int i = 0; i < contours.size(); i++ )
     {	
     	approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
       	boundRect[i] = boundingRect( Mat(contours_poly[i]) );
       	double height = boundRect[i].height;
       	double width = boundRect[i].width;
     	double area = contourArea(contours[i]);

     	if (area > 3000)
     	drawContours(black, contours, i, Scalar(0,255,0), 2, 8, hierarchy, 0, Point() );
    	//drawContours(frame, contours, i, Scalar(0,255,0), 2, 8, hierarchy, 0, Point() );
    	
    	//These conditions have to be calibrated and tested with the MAV
    	if (area > maxArea && height<200 && width<200 && height >0 && width>0)
    	{	
        	//cout<<area<<"\n";
        	mu[i] = moments( contours[i], false); //c = max(cnts, key=cv2.contourArea)
       		mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
       		//Drawing center of black contours
       		circle(black, mc[i], 4, Scalar(0,0,255), -1, 8, 0 );
   
      	}
       	
      
     }
	
	//Line Detection. Edges are detected in the black image and lines are detected on that.
	Canny(black, black_edges,lowThreshold,lowThreshold*ratio,kernel_size );
	HoughLines(black_edges, lines, 1, CV_PI/180, 50, 0, 0 );
	
	//Drawing lines
	for( size_t i = 0; i < lines.size(); i++ )
    {
        float rho = lines[i][0], theta = lines[i][1];
        Point pt1, pt2;
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        line(black_edges, pt1, pt2, Scalar(255,0,0),2, CV_AA);  
    }
 	

 	imshow( "Frame", frame );
	imshow("black",black);
	imshow("black edges",black_edges);

}
 
int main(){

  VideoCapture cap(0); 
  if(!cap.isOpened()){
    cout << "Error opening video stream or file" << endl;
    return -1;
  }
     
  while(1){
 
    Mat frame;
    cap >> frame;
    if (frame.empty())
      break;
  	
  	cvtColor(frame, gray, CV_BGR2GRAY );
  	
  	
  	CannyEdge(frame);
 
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