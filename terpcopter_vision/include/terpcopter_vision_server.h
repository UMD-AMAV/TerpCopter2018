// THIS HEADER FILE CONTAINS THE DECLARATION OF THE VARIABLES AND FUNCTIONS OF 
// TERPCOPTER VISION SERVER
//
// COPYRIGHT BELONGS TO THE AUTHOR OF THIS CODE
//
// AUTHOR : LAKSHMAN KUMAR
// AFFILIATION : UNIVERSITY OF MARYLAND, MARYLAND ROBOTICS CENTER
// EMAIL : LKUMAR93@TERPMAIL.UMD.EDU
// LINKEDIN : WWW.LINKEDIN.COM/IN/LAKSHMANKUMAR1993
//
// THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
// THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
// THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
// PROHIBITED.
// 
// BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
// BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
// CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
// CONDITIONS.
//

#ifndef TERPCOPTER_VISION_SERVER_H_
#define TERPCOPTER_VISION_SERVER_H_

///////////////////////////////////////////
//
//	LIBRARIES
//
///////////////////////////////////////////

#include <string>

#include "ros/ros.h"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/videostab.hpp>
#include <sensor_msgs/image_encodings.h>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>

#include "terpcopter_comm/DetectObject.h"

///////////////////////////////////////////
//
//	DEFINITIONS
//
///////////////////////////////////////////

 //Hue values of basic colors

 // Orange  0-22
 // Yellow 22- 38
 // Green 38-75
 // Blue 75-130
 // Violet 130-160
 // Red 160-179
 // Black V 0-30

#define LOW_H_YELLOW 22
#define LOW_S_YELLOW 23
#define LOW_V_YELLOW 0
#define HIGH_H_YELLOW 38
#define HIGH_S_YELLOW 255
#define HIGH_V_YELLOW 255

#define LOW_H_BLACK 0
#define LOW_S_BLACK 0
#define LOW_V_BLACK 0
#define HIGH_H_BLACK 179
#define HIGH_S_BLACK 255
#define HIGH_V_BLACK 30

#define CONTOUR_AREA_THRESHOLD 1000

///////////////////////////////////////////
//
//	NAMESPACES
//
///////////////////////////////////////////

using namespace cv;
using namespace std;

///////////////////////////////////////////
//
//	STRUCTS
//
/////////////////////////////////////////

struct ContourDataT
{
    Mat image_of_contours;
    int center_x;
    int center_y;
    float area;
    float arc_length;
    float width;
    float height;
    int number_of_contours;
    int number_of_vertices;
    bool detection_flag;
    bool is_convex;

};

///////////////////////////////////////////
//
//	ROS VARIABLES
//
/////////////////////////////////////////

ros::ServiceServer boundary_detection_service, home_base_detection_service;

///////////////////////////////////////////
//
//	FUNCTIONS
//
/////////////////////////////////////////


Mat detect_color(const Mat& input_image, int LOW_H, int LOW_S, int LOW_V,int HIGH_H, int HIGH_S, int HIGH_V, bool morphological_operation);
Mat combine_images(const Mat& input_image1, const Mat& input_image2);
ContourDataT find_contours(const Mat& input_image);
bool detect_boundary(terpcopter_comm::DetectObject::Request  &request,
         terpcopter_comm::DetectObject::Response &response);
bool detect_home_base(terpcopter_comm::DetectObject::Request  &request,
         terpcopter_comm::DetectObject::Response &response);


#endif // TERPCOPTER_VISION_SERVER_H_
