//
// THIS HEADER FILE CONTAINS THE DECLARATION OF THE VARIABLES AND FUNCTIONS OF 
// THE CAMERA PUBLISHER CLASS
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

#ifndef TERPCOPTER_CAMERA_NODE_H_
#define TERPCOPTER_CAMERA_NODE_H_

///////////////////////////////////////////
//
//	LIBRARIES
//
///////////////////////////////////////////

#include <string>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/videostab.hpp>
#include <image_transport/image_transport.h>

///////////////////////////////////////////
//
//	NAMESPACES
//
///////////////////////////////////////////

using namespace cv;
using namespace std;

///////////////////////////////////////////
//
//	CLASS DECLARATIONS
//
///////////////////////////////////////////


//Publishes images from the camera as a ROS message

class CameraPublisher
{  
  string camera_position;
  int camera_input_id ;
  VideoCapture video_capture_port;
  Mat input_image;
  Mat denoised_image;
  image_transport::CameraPublisher camera_pub;
  string prefix = "terpcopter/cameras/";
  string postfix = "/image" ;
  string camera_topic_name ;
  sensor_msgs::CameraInfo* camera_info;
  sensor_msgs::CameraInfoPtr camera_info_ptr;
  cv::Mat_<float> camera_matrix;
  cv::Mat_<float> distortion_params;

  public:

  CameraPublisher(string position, int id, double focal_length_x ,double principal_point_x ,
		  double focal_length_y, double principal_point_y, double* distortion_array,
		  image_transport::ImageTransport ImageTransporter);

  bool Initialize();
  
  void Publish();
  
};


#endif // TERPCOPTER_CAMERA_NODE_H_
