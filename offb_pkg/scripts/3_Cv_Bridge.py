#!/usr/bin/env python
# Black Squares detection
from __future__ import print_function
import roslib
roslib.load_manifest('offb_pkg')
import sys
import rospy
import cv2
from std_msgs.msg import String
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
from sensor_msgs.msg import CompressedImage
import numpy as np


class image_converter:

  def __init__(self):
    self.image_pub = rospy.Publisher("image_topic_2",Image,queue_size=10)

    self.bridge = CvBridge()
    self.image_sub = rospy.Subscriber("/camera/image/compressed",CompressedImage,self.callback)

  def callback(self,ros_data):
    try:
      np_arr = np.fromstring(ros_data.data, np.uint8)
      cv_image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
      cv_image = cv2.pyrDown(cv_image)
      cv_image = cv2.pyrDown(cv_image)
      #cv_image = self.bridge.imgmsg_to_cv2(data, "bgr8")
    except CvBridgeError as e:
      print(e)

    (rows,cols,channels) = cv_image.shape
    hsv = cv2.cvtColor(cv_image, cv2.COLOR_BGR2HSV)

    lower_black = np.array([0,0,0])  #0,50,50 for red 0 0 0 
    upper_black = np.array([180,255,50]) # 10, 255, 255 for red 180 255 50
    mask = cv2.inRange(hsv, lower_black, upper_black)
    
    res = cv2.bitwise_and(cv_image,cv_image, mask= mask) #Result of the masking
    #_, contours, _ = cv2.findContours(mask.copy(), cv2.RETR_CCOMP, cv2.CHAIN_APPROX_TC89_L1)
    cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)[-2]
    
  
    center_black = None
    

    for contour in cnts:
      area = cv2.contourArea(contour)
      rect = cv2.minAreaRect(contour)
      width = rect[1][0]
      height = rect[1][1]
      if (width < 500) and (height < 500) and (width >= 0) and (height > 0) and (area>1000):
        c = max(cnts, key=cv2.contourArea)
        ((x, y), radius) = cv2.minEnclosingCircle(c)
        M = cv2.moments(c)
        center_black = (int(M["m10"] / M["m00"]), int(M["m01"] / M["m00"]))
        print(center_black)
        #cv2.circle(mask, centres[-1], 3, (0, 0, 0), -1)
        cv2.circle(cv_image, center_black, 3, (255, 255, 255), -1) #draws the centroid as a white dot
        cv2.drawContours(cv_image, contour, -1, (0,255,0), 3) #Draws contours in green
        #rect = cv2.minAreaRect(contour)
        #box = cv2.boxPoints(rect)
        #box = np.int0(box)
        #cv_image = cv2.drawContours(cv_image,[box],0,(0,0,255),2)
    
    
    cv2.imshow("Image window", cv_image)
    cv2.imshow("Mask", mask)
    cv2.imshow("Res", res)
    #cv2.imshow("Mask", mask)
    cv2.waitKey(3)

    try:
      self.image_pub.publish(self.bridge.cv2_to_imgmsg(cv_image, "bgr8"))
    except CvBridgeError as e:
      print(e)

def main(args):
  ic = image_converter()
  rospy.init_node('image_converter', anonymous=True)
  try:
    rospy.spin()
  except KeyboardInterrupt:
    print("Shutting down")
  cv2.destroyAllWindows()

if __name__ == '__main__':
    main(sys.argv)
