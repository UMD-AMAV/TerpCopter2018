
//
// THIS HEADER FILE CONTAINS LIBRARIES AND FUNCTION FOR TERPCOPTER MISSION
//
// COPYRIGHT BELONGS TO THE AUTHOR OF THIS CODE
//
// AUTHOR : AUSTIN MAHOWALD
// AFFILIATION : UNIVERSITY OF MARYLAND 
// EMAIL : 
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

#pragma once

#include <ros/ros.h>
#include <string>
#include <vector>
#include <cmath>
#include <list>
#include <cstdio>
#include <ctime>

using namespace std;

class pathPlanning {
	public:
		int ROW,COL,TI,TJ;
		pathPlanning(int r,int c, int t_i, int t_j){
  			ROW = r;
  			COL = c;
  			TI = t_i;
  			TJ = t_j;
			};
		struct node {
			node();
			int i,j;
			double g,h,f;
		};
		bool isValid(node nd, vector<node> &closedList, vector<node> &openList);
		bool isGoal(node nd);
		bool isBlocked(node nd, vector<int> &obstacleRow, vector<int> &obstacleCol);
		double calcH(node nd);
		void mapToLoc(vector<int> &map, vector<int> &obstacleRow,
			vector<int> &obstacleCol);
		node genSuccessor(node q, int dir);
		void aStarPlan(int c_i, int c_j, vector<node> &waypoint, vector<int> &map);
		void reverseSearch(vector<node> &closedList, vector<node> &waypoints);
		~pathPlanning();
};
