#!/usr/bin/env python
from __future__ import print_function
import sys
import numpy as np
from geometry_msgs.msg import PoseStamped , Pose
from terpcopter_comm.srv import * 
import rospy
from transforms3d import quaternions as quat


targetlocalPose = PoseStamped()
quadPose = PoseStamped()
t_pose = Pose()
t_I_Pose_X = [] #np.zeros(100)
t_I_Pose_Y =[]
t_I_Pose_Z = []

def Redtragetcallback(msg):
        #print("cb)")
        targetlocalPose.pose.position = msg.pose.position
        targetlocalPose.pose.orientation = msg.pose.orientation

def Quadcallback(msg):
        #print("quad")
        quadPose.pose.position = msg.pose.position
        quadPose.pose.orientation = msg.pose.orientation

        #  transformation()

    #def transformation():
        #print ("transformation")
        t_C_T = np.array([[  targetlocalPose.pose.position.x/100],
                          [  targetlocalPose.pose.position.y/100],
                          [  targetlocalPose.pose.position.z/100]])

        #print('tct: ', t_C_T)
        #print ('R_I_D',   quadPose.pose.orientation)

        R_I_D = quat.quat2mat([  quadPose.pose.orientation.x,
                                 quadPose.pose.orientation.y,
                                 quadPose.pose.orientation.z,
                                 quadPose.pose.orientation.w])
                                    
        R_D_C = np.eye(3)

        t_I_D =  np.array([[  quadPose.pose.position.x],
                          [  quadPose.pose.position.y],
                          [  quadPose.pose.position.z]])

        R_I_C = R_I_D * R_D_C
        t_I_T = t_I_D + (R_I_C.dot(t_C_T))

        i=0

        while True:
            t_I_Pose_X.append(t_I_T[0])
            t_I_Pose_Y.append(t_I_T[1])
            t_I_Pose_Z.append(t_I_T[2])
            i=i+1

            if i == 100:
                #print('this is 100')
                break

def handle_avg_pose(req):
        
        print("handle_avg_pose")
        t_pose.position.x = np.mean( t_I_Pose_X)
        t_pose.position.y = np.mean( t_I_Pose_Y)
        t_pose.position.z = np.mean( t_I_Pose_Z)
        rospy.loginfo(rospy.get_caller_id() + "I heard %s",t_pose)
        
        return DetectTargetPoseResponse(t_pose)

    # def targetService(  :
    #     print('targetSer')
    #     s = rospy.Service('target_Inertial_Pose',DetectObject,   handle_avg_pose)

if __name__ == '__main__':

    rospy.init_node('target_Inertial_Pose_server',anonymous = True)
    red_target_localpose_sub = rospy.Subscriber("/redTargetPose",PoseStamped, Redtragetcallback)
    quadpose_sub = rospy.Subscriber("mavros/local_position/pose", PoseStamped, Quadcallback)
    s = rospy.Service('target_Inertial_Pose',DetectTargetPose, handle_avg_pose)

    try:
        rospy.spin()
    except KeyboardInterrupt:
        print("Shutting down")

    
    
    
