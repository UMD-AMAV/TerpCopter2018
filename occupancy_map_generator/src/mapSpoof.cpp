
#include <mapSpoof.h>

using namespace std;

// state_sub
mapSpoof::mapSpoof()
{}

void mapSpoof::createMap(vector<int> &map, int arena_width, int arena_height,
      int boundary_width, int obstacle_width, int obstacle_height, int obstacle_loc) {

  map.resize(arena_height*arena_width,int(0));

  ////// Grid boundary

  for(int i=0;i<arena_height;i++){
    for(int j=0;j<boundary_width;j++){
      map.at(i*arena_width+j)=100;
      map.at(i*arena_width+arena_width-1-j)=100;
    }
  }

  for(int i=0;i<arena_width;i++){
    for(int j=0;j<boundary_width;j++){
      map.at(i+j*arena_width)=100;
      map.at(arena_width*arena_height-1-i-j*arena_width)=100;
    }
  }

  ////// Add obstacle to occupancy grid

  for(int i=0;i<obstacle_height;i++){
    for(int j=0;j<obstacle_width;j++){
      map.at(j+obstacle_loc+arena_width*i)=100;
    }
  }
}

mapSpoof::~mapSpoof()
{}