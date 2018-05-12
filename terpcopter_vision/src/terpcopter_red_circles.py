#!/usr/bin/env python
from __future__ import print_function
import roslib
import sys
import rospy
import cv2
from std_msgs.msg import String
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
from sensor_msgs.msg import CompressedImage
from geometry_msgs.msg import PoseStamped

import numpy as np
#from transforms3d import quaternions


class image_converter:

  def __init__(self):
    #print ("self")
    self.image_pub = rospy.Publisher("/red_detection",Image,queue_size=10)
    self.redtarget_pos = rospy.Publisher("/redTargetPose", PoseStamped, queue_size=10 )

    self.bridge = CvBridge()
    self.image_sub = rospy.Subscriber("/iris/camera_red_iris/image_raw",Image,self.callback)
    
  def callback(self,ros_data):
    try:
      cv_image = self.bridge.imgmsg_to_cv2(ros_data, "bgr8")
      #print("line 29")
    except CvBridgeError as e:
      print(e)
    
    msg = PoseStamped()

        # 3D model points.
    model_points = np.array([
                            #ENU frame
                            (0.0, 0.0, 0.0), # center
                            (50.0, 0.0, 0.0), #up corner
                            (-50.0, 0.0, 0.0), #down corner
                            (0.0, 50.0, 0.0), # left corner
                            (0.0, -50.0 , 0.0), #right corner
                            
                          ])


        # Camera internals
    camera_matrix = np.array(
                          [[476.70308, 0, 400.5],
                          [0,476.70308, 400.5],
                          [0, 0, 1]], dtype = "double"
                            )
                          
    dist_coeffs = np.array([ [0.0],   [0.0],   [0.0],   [0.0],  [0.0] ])

    (rows,cols,channels) = cv_image.shape
    median = cv2.medianBlur(cv_image,5)
    gauss = cv2.GaussianBlur(median,(11,11),0) 
    hsv = cv2.cvtColor(gauss, cv2.COLOR_BGR2HSV)

    lower_red = np.array([0,50,50])  #0,50,50 for red 0 0 0 
    upper_red = np.array([10,255,255]) # 10, 255, 255 for red 180 255 50
    mask0 = cv2.inRange(hsv, lower_red, upper_red)

     # upper mask (170-180)
    lower_red = np.array([170,50,50])
    upper_red = np.array([180,255,255])
    mask1 = cv2.inRange(hsv, lower_red, upper_red)

    mask = mask0 + mask1
    
    kernel= cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(7,7))
    mask = cv2.dilate(mask, kernel, iterations = 1)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    #cv2.imshow("mask",mask)

    cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[-2]
    center_red = None

    for contour in cnts:
      area = cv2.contourArea(contour)
      rect = cv2.minAreaRect(contour)

      width = rect[1][0]
      height = rect[1][1]

      if (width < 500) and (height < 500) and (width >= 0) and (height > 0) and (area>1000):
        c = max(cnts, key=cv2.contourArea)
        #((x, y), radius) = cv2.minEnclosingCircle(c)

        ellipse = cv2.fitEllipse(c)
        cv2.ellipse(cv_image,ellipse,(0,255,0),2)

        M = cv2.moments(c)
        #center_red = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))
        center = (int(ellipse[0][0]),int(ellipse[0][1]))

        if center == None:
          #print("continue")
          #msg.header.frame_id = "redTargetDetected"
          continue
        else:
          minradius = ellipse[1][0]/2
          majradius = ellipse[1][1]/2

          #2D image points. If you change the image, you need to change vector
          image_points = np.array([
                            (center[0] , center[1]), # center
                            (center[0] , center[1] - minradius), # up corner
                            (center[0] , center[1] + minradius), # down corner
                            (center[0] - majradius, center[1]), # left corner
                            (center[0] + majradius, center[1]), # right corner
                        ], dtype="double")
          
          (success, rotation_vector, translation_vector) = cv2.solvePnP(model_points, image_points, camera_matrix, dist_coeffs, flags=cv2.SOLVEPNP_ITERATIVE)

          Rt = cv2.Rodrigues(rotation_vector)[0]
          #quat= quaternions.mat2quat(Rt)
       

          y_pos= np.array(translation_vector[0],dtype=float)*0.01 #m
          x_pos= np.array(translation_vector[1],dtype=float)*0.01 #m
          z_pos= np.array(translation_vector[2],dtype=float)*0.01 #m

          cv2.putText(cv_image, "Z: %.2fm" % z_pos, (150,  300),
              cv2.FONT_HERSHEY_SIMPLEX,
              1.0, (0, 255, 0), 3)

          cv2.putText(cv_image, "X: %.2fm" % x_pos, (450,  300), #swapped x and y to make it work
              cv2.FONT_HERSHEY_SIMPLEX,
              1.0, (0, 255, 0), 3)

          cv2.putText(cv_image, "Y: %.2fm" % y_pos, (150,  500),
              cv2.FONT_HERSHEY_SIMPLEX,
              1.0, (0, 255, 0), 3)
        
          msg.header.stamp= rospy.Time.now()
          msg.header.frame_id = "redTargetDetected"
          msg.pose.position.x=x_pos
          msg.pose.position.y=y_pos
          msg.pose.position.z=z_pos

##          msg.pose.orientation.x = quat[0]
##          msg.pose.orientation.y = quat[1]
##          msg.pose.orientation.z = quat[2]
##          msg.pose.orientation.w = quat[3]

          (nose_end_point2D, jacobian) = cv2.projectPoints(np.array([(0.0, 0.0, 1000.0)]), rotation_vector, translation_vector, camera_matrix, dist_coeffs)

          for p in image_points:
              cv2.circle(cv_image, (int(p[0]), int(p[1])), 8, (0,0,255), -1)

              p1 = ( int(image_points[0][0]), int(image_points[0][1]))
              p2 = ( int(nose_end_point2D[0][0][0]), int(nose_end_point2D[0][0][1]))

              cv2.line(cv_image, p1, p2, (255,0,0), 2)
    
    
    cv2.imshow("Image window", cv_image)
    # cv2.imshow("Mask", mask)
    cv2.waitKey(3)

    try:
      self.image_pub.publish(self.bridge.cv2_to_imgmsg(cv_image, "bgr8"))
      self.redtarget_pos.publish(msg)
      #
    except CvBridgeError as e:
      print(e)

def main(args):
  rospy.loginfo('Red detection')
  ic = image_converter()
  rospy.init_node('terpcopter_vision_red', anonymous=True)
  try:
    rospy.spin()
  except KeyboardInterrupt:
    rospy.loginfo("terpcopter_vision_red shutting down")
  cv2.destroyAllWindows()

if __name__ == '__main__':
    main(sys.argv)
