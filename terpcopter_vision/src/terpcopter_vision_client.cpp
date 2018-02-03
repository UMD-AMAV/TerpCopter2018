//
// THIS FILE CONTAINS A SAMPLE IMPLEMENTATION OF A CLIENT TO 
// VISION SERVICES
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

///////////////////////////////////////////
//
//	LIBRARIES
//
///////////////////////////////////////////

#include <string>

#include "ros/ros.h"
#include "ros/package.h"
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/videostab.hpp>
#include <sensor_msgs/image_encodings.h>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>

#include "terpcopter_comm/DetectObject.h"

///////////////////////////////////////////
//
//	NAMESPACE
//
///////////////////////////////////////////

using namespace cv;

///////////////////////////////////////////
//
//	MAIN FUNCTION
//
///////////////////////////////////////////

int main(int argc, char **argv)
{
  ros::init(argc, argv, "terpcopter_vision_client");
  ros::NodeHandle n;
  
  std::string image_path1 = ros::package::getPath("terpcopter_vision") + "/images/caution_tape_noisy_2.jpg";
  std::string image_path2 = ros::package::getPath("terpcopter_vision") + "/images/home_base_noisy_2.jpg";
  Mat image1 = imread( image_path1, 1 );
  Mat image2 = imread( image_path2, 1 );

  if ( !image1.data || !image2.data )
    {
        ROS_INFO("No image data \n");
        return -1;
    }

  //Convert OpenCV Mat to ROS Msg
  sensor_msgs::ImagePtr msg1, msg2;
  msg1  = cv_bridge::CvImage(std_msgs::Header(), "bgr8", image1).toImageMsg();
  msg1->header.stamp = ros::Time::now() ;

  msg2  = cv_bridge::CvImage(std_msgs::Header(), "bgr8", image2).toImageMsg();
  msg2->header.stamp = ros::Time::now() ;

  //Create a client for detect_boundary service
  ros::ServiceClient boundary_detection_client = n.serviceClient<terpcopter_comm::DetectObject>("detect_boundary");
  ros::ServiceClient home_base_detection_client = n.serviceClient<terpcopter_comm::DetectObject>("detect_home_base");

  terpcopter_comm::DetectObject srv1,srv2;

  //Send the image as a request to the service
  srv1.request.input_image = *msg1;
  srv2.request.input_image = *msg2;

  //Call the service, if its a success display the data of the largest contour
  if(boundary_detection_client.call(srv1))
  {
	if(srv1.response.detection_flag)	
		ROS_INFO("Boundary Client : Center X = %d, Center Y = %d, Area = %f, Width = %d, Height = %d",srv1.response.center_x_pixel,srv1.response.center_y_pixel,srv1.response.area, srv1.response.width,srv1.response.height);
	else
		ROS_INFO("Boundary not found");
  }
  else
   {
	ROS_ERROR("Failed to call service detect_boundary");
	return 1;
   }


  if(home_base_detection_client.call(srv2))
  {
	if(srv2.response.detection_flag)	
		ROS_INFO("Home Base Client : Center X = %d, Center Y = %d, Area = %f,  Width = %d, Height = %d", srv2.response.center_x_pixel, srv2.response.center_y_pixel, srv2.response.area, srv2.response.width,srv2.response.height);
	else
		ROS_INFO("Home Base not found");
  }
  else
   {
	ROS_ERROR("Failed to call service detect_home_base");
	return 1;
   }


  return 0;
}	
