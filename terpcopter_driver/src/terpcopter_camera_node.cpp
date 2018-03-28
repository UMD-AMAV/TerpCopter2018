//
// THIS FILE CONTAINS THE IMPLEMENTATION FOR PUBLISHING IMAGES FROM THE CAMERA 
// AS A ROS MESSAGE USING THE CAMERA PUBLISHER CLASS
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

#include <terpcopter_driver/terpcopter_camera_node.h>
#include <terpcopter_driver/terpcopter_camera_parameters.h>

#include <ros/ros.h>
#include <sensor_msgs/image_encodings.h>
#include <cv_bridge/cv_bridge.h>
#include <camera_info_manager/camera_info_manager.h>

///////////////////////////////////////////
//
//	MEMBER FUNCTIONS
//
///////////////////////////////////////////

// Use the constructor to initialize variables
CameraPublisher::CameraPublisher(string position, int id, double focal_length_x, double principal_point_x ,
				 double focal_length_y, double principal_point_y, double* distortion_array,
				 image_transport::ImageTransport ImageTransporter)

				 :camera_matrix(3,3), distortion_params(1,5)

{
	camera_position = position ;
	camera_input_id = id ;	
	camera_topic_name = prefix + camera_position + postfix ;
	camera_pub = ImageTransporter.advertiseCamera(camera_topic_name, 1);
	
	camera_info = new sensor_msgs::CameraInfo ();
	camera_info_ptr = sensor_msgs::CameraInfoPtr (camera_info);

	camera_info_ptr->header.frame_id = camera_position+"_camera";
	camera_info->header.frame_id = camera_position+"_camera";
	camera_info->width = 640;
	camera_info->height = 480;

	// Camera Matrix

	camera_info->K.at(0) = focal_length_x;
	camera_info->K.at(2) = principal_point_x;
	camera_info->K.at(4) = focal_length_y;
	camera_info->K.at(5) = principal_point_y;
	camera_info->K.at(8) = 1;
	camera_info->P.at(0) = camera_info->K.at(0);
	camera_info->P.at(1) = 0;
	camera_info->P.at(2) = camera_info->K.at(2);
	camera_info->P.at(3) = 0;
	camera_info->P.at(4) = 0;
	camera_info->P.at(5) = camera_info->K.at(4);
	camera_info->P.at(6) = camera_info->K.at(5);
	camera_info->P.at(7) = 0;
	camera_info->P.at(8) = 0;
	camera_info->P.at(9) = 0;
	camera_info->P.at(10) = 1;
	camera_info->P.at(11) = 0;
	camera_info->distortion_model = "plumb_bob";

	// Make Rotation Matrix an identity matrix
	camera_info->R.at(0) = (double) 1;
	camera_info->R.at(1) = (double) 0;
	camera_info->R.at(2) = (double) 0;
	camera_info->R.at(3) = (double) 0;
	camera_info->R.at(4) = (double) 1;
	camera_info->R.at(5) = (double) 0;
	camera_info->R.at(6) = (double) 0;
	camera_info->R.at(7) = (double) 0;
	camera_info->R.at(8) = (double) 1;

	for (int i = 0; i < 5; i++)
	    camera_info->D.push_back (distortion_array[i]);

	camera_matrix << focal_length_x, 0, principal_point_x, 0, focal_length_y,principal_point_y, 0, 0, 1 ;
	distortion_params << distortion_array[0],distortion_array[1],distortion_array[2],distortion_array[3],distortion_array[4];

}

// Initialize the camera
bool CameraPublisher::Initialize()
{
	video_capture_port.open(camera_input_id);

	if( !video_capture_port.isOpened() )
	    {
		ROS_ERROR("Camera with id : %d cannot be found ", camera_input_id);
		return false;
	    }

	return true;

}

// Publish the images from the camera to the corresponding topic
void CameraPublisher::Publish()
{
	video_capture_port >> input_image;

	if( input_image.empty() )
	{
		ROS_INFO("No image from camera with id : %d ", camera_input_id);
	}
	else
	{
	    sensor_msgs::ImagePtr msg;

	    // Remove noise from the images using Gaussian Blur and Median Blur
	    GaussianBlur(input_image, input_image, Size(5,5),0,0);
	    medianBlur(input_image, denoised_image,5);

	    msg  = cv_bridge::CvImage(std_msgs::Header(), "bgr8", denoised_image).toImageMsg();
	    msg->header.stamp = ros::Time::now() ;
	    msg->header.frame_id = camera_position+"_camera";

	    camera_info->header.stamp = ros::Time::now();

	    camera_pub.publish(msg, camera_info_ptr) ;
	}
}
  

///////////////////////////////////////////
//
//	MAIN FUNCTION
//
///////////////////////////////////////////

int main( int argc, char** argv )
{    
    //Initialize the Terpcopter Camera Node
    ros::init(argc, argv, "terpcopter_camera_node");

    //Initialize the ROS Node Handle and expose it to Image Transporter
    ros::NodeHandle nh;
    image_transport::ImageTransport image_transporter(nh);
 
    int camera_id;
	
    //If available, get the camera id parameter from the node handle 
    //Else use the default id : 0
    nh.param<int>("terpcopter_camera_node/forward_camera_id", camera_id, 0);

    //Create a publisher for the forward facing camera with the measured calibration paramerers
    CameraPublisher forward_camera_pub("forward", camera_id, FOCAL_LENGTH_X,FOCAL_LENGTH_Y, PRINCIPAL_POINT_X,
				       PRINCIPAL_POINT_Y, DISTORTION_PARAMS, image_transporter);

    //Initialize the camera and check for errors
    bool Initialized = forward_camera_pub.Initialize();    

    //If the camera has been initialized and ROS node handle is working , publish the images from the camera
    while(nh.ok() && Initialized)
    {
	forward_camera_pub.Publish() ;
    }
     
    return 0;
}
