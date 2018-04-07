
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

using namespace std;

class mapSpoof {

	public:
		mapSpoof();
		~mapSpoof();
		void createMap(vector<int> &map, int arena_width, int arena_height, 
			int boundary_width, int obstacle_width, int obstacle_height, int obstacle_loc);
	private:
		
};
