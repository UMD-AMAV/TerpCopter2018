#!/usr/bin/env python 

import sys
import rospy
import roslib
from terpcopter_comm.srv import *

def handle_avg_pose_client():
    rospy.wait_for_service('target_Inertial_Pose')
    try:
        print('client')
        target_Inertial_Pose = rospy.ServiceProxy('target_Inertial_Pose',DetectTargetPose)
        req= 
        print(req)
        resp = target_Inertial_Pose(req)
        print resp
        return resp
    except rospy.ServiceException, e:
        print"Service call failed: %s" %e
        
if __name__ == "__main__":
    handle_avg_pose_client()

