#!/usr/bin/env python
from __future__ import print_function

import roslib
#roslib.load_manifest('terpcopter_vision')
import sys
import rospy
import numpy as np
#from transforms3d import quaternions
import cv2
from std_msgs.msg import String
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
from math import sqrt
#from geometry_msgs.msg import Twist
from geometry_msgs.msg import PoseStamped

#cent_msg = Twist()
class image_converter:

  def __init__(self):
    self.image_pub = rospy.Publisher("/homebase_detection",Image,queue_size=10)
    self.hometarget_pos = rospy.Publisher("/homeTargetPose", PoseStamped, queue_size=10 )
    #self.centroid_pub = rospy.Publisher('/HomebaseCentroid', Twist, queue_size=10)
    
    self.bridge = CvBridge()
    self.image_sub = rospy.Subscriber("/iris/camera_red_iris/image_raw",Image,self.callback)

  def callback(self,data):
    try:
        lower = np.array([180, 165, 180], dtype = "uint8")
        upper = np.array([255, 255, 255], dtype = "uint8")
        cv_image = self.bridge.imgmsg_to_cv2(data, "bgr8")

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

        
        #Isolate the HomeBase from surrounding
        Hmask = cv2.inRange(cv_image,lower,upper)
        maskedImage = cv2.bitwise_and(cv_image,cv_image,mask = Hmask)
        
        #Convert Masked Image to Grayscale
        maskedImage = cv2.GaussianBlur(maskedImage,(5,5),0)
        maskedImageGray = cv2.cvtColor(maskedImage, cv2.COLOR_BGR2GRAY)
        
        #Circle Detection
        circles = cv2.HoughCircles(maskedImageGray, cv2.HOUGH_GRADIENT, 1.2, 100)

        if circles is not None:
            # convert the (x, y) coordinates and radius of the circles to integers
            circles = np.round(circles[0, :]).astype("int")
    
    
            #Draw the circle
            for (x, y, r) in circles:
                cv2.circle(cv_image, (x, y), r, (0, 255, 0), 4)
                cv2.rectangle(cv_image, (x - 3, y - 3), (x + 3, y + 3), (0, 128, 255), -1)
                #Defining ROI
                s = int(r/sqrt(2))

                Ky = y-s
                Kx = x-s
                if Ky < 0:
                    Ky = 0
                if Kx < 0:
                    Kx = 0

                ROI = cv_image[Ky:y+s, Kx:x+s]
                ROImask = cv2.inRange(ROI,lower,upper)
                maskedROI = cv2.bitwise_and(ROI,ROI,mask = ROImask)
                maskedROI = cv2.GaussianBlur(maskedROI,(5,5),0)
                maskedROIGray = cv2.cvtColor(maskedROI, cv2.COLOR_BGR2GRAY)
                maskedROIBin = cv2.threshold(maskedROIGray,60,255,cv2.THRESH_BINARY)[1]

                #Get contours
                cnts = cv2.findContours(ROImask.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[-2]
                Hcenter = None
                center = np.array([0, 0])
                c = max(cnts, key=cv2.contourArea)
                M = cv2.moments(c)
                Hcenter = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))

                cv2.circle(ROI, Hcenter, 3, (255, 255,0), -1) #Drawing the H center
                #print(Hcenter[0] + Kx, Hcenter[1] + Ky, x, y)

                if (Hcenter[0]+Kx >= x-3 and Hcenter[0]+Kx<= x+3 and Hcenter[1]+Ky <= y+3 and Hcenter[1] + Ky >= y-3):
                    print("Homebase Detected")
                    center[0] = Hcenter[0]+Kx
                    center[1] = Hcenter[1]+Ky
                    #self.centroid_pub.publish(cent_msg)
                    image_points = np.array([
                            (center[0] , center[1]), # center
                            (center[0] , center[1] - r), # up corner
                            (center[0] , center[1] + r), # down corner
                            (center[0] - r, center[1]), # left corner
                            (center[0] + r, center[1]), # right corner
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

##                    msg.pose.orientation.x = quat[0]
##                    msg.pose.orientation.y = quat[1]
##                    msg.pose.orientation.z = quat[2]
##                    msg.pose.orientation.w = quat[3]

                    (nose_end_point2D, jacobian) = cv2.projectPoints(np.array([(0.0, 0.0, 1000.0)]), rotation_vector, translation_vector, camera_matrix, dist_coeffs)

                    for p in image_points:
                        cv2.circle(cv_image, (int(p[0]), int(p[1])), 8, (0,0,255), -1)
                        p1 = ( int(image_points[0][0]), int(image_points[0][1]))
                        p2 = ( int(nose_end_point2D[0][0][0]), int(nose_end_point2D[0][0][1]))
                        cv2.line(cv_image, p1, p2, (255,0,0), 2)

                    self.image_pub.publish(self.bridge.cv2_to_imgmsg(cv_image, "bgr8"))
                    self.hometarget_pos.publish(msg)
                #Draw Contours
                #cv2.drawContours(ROI, cnts, -1, (0,0,255), 3)
                
        cv2.imshow('Images',np.hstack([cv_image, maskedImage]))
        #cv2.imshow('Masked Binary ROI',maskedROIBin)
        cv2.waitKey(3)

    except CvBridgeError as e:
      print(e)

    
def main(args):
  rospy.loginfo('HomeBase detection')
  ic = image_converter()
  rospy.init_node('terpcopter_vision_homebase', anonymous=True)
  try:
    rospy.spin()
  except KeyboardInterrupt:
    rospy.loginfo("Terpcopter_vision_gomebase shutting down")
  cv2.destroyAllWindows()

if __name__ == '__main__':
    main(sys.argv)
