#include <pathPlanning.h>

using namespace std;

struct node {
  node();
  //node(int i1, int j1, double g1, double h1, double f1)
  //   { i = i1; j = j1; g = g1; h = h1; f = f1; }
  //node(const node &NODE) { i = NODE.i; j = NODE.j; g = NODE.g; h = NODE.h; f = NODE.f; }
  int i,j;
  double g,h,f;
  //~node(){}
};

pathPlanning::node::node()
{
  i = 0;
  j = 0;
  g = 0.0;
  h = 0.0;
  f = 0.0;
}

bool pathPlanning::isValid(node nd, vector<node> &openList, vector<node> &closedList){
  cout<<"Checking if node is valid..."<<endl;
  bool valid = true; // heap search
    for(int k=openList.size()-1;k>=0;k--){
      if(openList[k].i == nd.i && openList[k].j == nd.j){
        if(openList[k].g > nd.g){
          openList[k].g = nd.g;
        }
        valid = false;
        cout<<"Node is in open list"<<endl;
      }
    }
    for(int z=closedList.size()-1;z>=0;z--){
      if(closedList[z].i == nd.i && closedList[z].j == nd.j){ 
        valid = false;
        cout<<"Node is in closed list"<<endl;
      }
    }
    if((nd.i < 0) || (nd.i > 20) || (nd.j < 0) || (nd.j > 60)){
      valid = false;
      cout<<"Node is out of range"<<endl;
      cout<<"Node row is "<<nd.i<<" node col is "<<nd.j<<" max is "<<ROW<<" "<<COL<<endl;
    }
  return valid;
  }

bool pathPlanning::isGoal(node nd){
  cout<<"Checking if node is goal..."<<endl;
  return (nd.i == TI && nd.j == TJ);
}

bool pathPlanning::isBlocked(node nd, vector<int> &obstacleRow, vector<int> &obstacleCol){
  cout<<"Checking if node is blocked..."<<endl;
  bool blocked = false;
  for(int y=obstacleCol.size()-1;y>=0;y--){
    if(obstacleRow.at(y) == nd.i && obstacleCol.at(y) == nd.j){
      blocked = true;
      cout<<"Node is in blocked"<<endl;
    }
  }
  return blocked;
}

double pathPlanning::calcH(node nd){
  return sqrt(10.0*(pow(TI-nd.i,2)+pow(TJ-nd.j,2))); 
}

void pathPlanning::mapToLoc(vector<int> &map, vector<int> &obstacleRow,
    vector<int> &obstacleCol){
  for(int i=0;i<map.size();i++){
    if(map[i]!= 0){
      obstacleCol.push_back((i+1)%COL);
      obstacleRow.push_back((i+1)/COL+1);
    }
  }
}

pathPlanning::node pathPlanning::genSuccessor(node q, int dir){
  node s;
  s.i = q.i;
  s.j = q.j;
  s.g = q.g;
  s.h = q.h;
  s.f = q.f;
  cout<<"Origin node row "<<q.i<<" node column "<<q.j<<endl;
  cout<<"Position "<<dir<<endl;
  if(dir==0 || dir==1 || dir==2){
    s.j = q.j+1;
  }
  else if(dir==5 || dir==6 || dir==7){
    s.j = q.j-1;
  }

  if(dir==7 || dir==3 || dir==2){
    s.i = q.i-1;
  }
  else if(dir==5 || dir==4 || dir==0){
    s.i = q.i+1;
  }

  if(dir==0 || dir==2 || dir==5 || dir==7){
    s.g = q.g + 14.0;
  }
  else if(dir==1 || dir==3 || dir==4 || dir==6){
    s.g = q.g + 10.0;
  }

  s.h = calcH(s);
  s.f = s.h + s.g;
  cout<<"Total cost of successor node is "<<s.f<<endl;
  cout<<"Successor node row is "<<s.i<<" and successor node column is "<<s.j<<endl;
  //cout<<"Successor node g cost is "<<s.g<<" and successor node h cost is "<<s.h<<"\n"<<endl;
  return s;
}

void pathPlanning::aStarPlan(int c_i, int c_j, vector<node> &closedList, vector<int> &map){
  vector<node> openList;
  vector<int> obstacleCol;
  vector<int> obstacleRow;

  mapToLoc(map,obstacleRow,obstacleCol);

  node o;
  o.i = c_i;
  o.j = c_j;
  o.g = 0.0;
  o.h = calcH(o);
  o.f = o.g + o.h;

  openList.push_back(node());
  openList[0].i = c_i;
  openList[0].j = c_j;
  openList[0].g = 0.0;
  openList[0].h = calcH(o);
  openList[0].f = o.g+o.h;

  while (openList.size()!=0) {
    cout<<"\nBeginning search loop"<<endl;
    
    double temp = 0.0;
    int idx = 0;
    
    for(int k=0;k<openList.size();k++){
      if(k==0){
        temp = openList[k].f;
      }
      else if(openList[k].f < temp){
        idx = k;
      }
    }
    node q;
    q.i = openList[idx].i;
    q.j = openList[idx].j;
    q.g = openList[idx].g;
    q.h = openList[idx].h;
    q.f = openList[idx].f;

    cout<<"Total cost of parent is "<<q.f<<endl;
    cout<<"Origin node row is "<<q.i<<" and origin node column is "<<q.j<<"\n\n"<<endl;
    openList.erase(openList.begin()+idx);

    for(int i=0;i<8;i++){
      node s; 
      s = genSuccessor(q,i);
      cout<<"Successor generated"<<endl;
      if(isGoal(s)){
        closedList.push_back(s);
        closedList.push_back(q);
        cout<<"Goal Reached!\n\n\n\n"<<endl;
        return;
      }
      else if(!isValid(s,openList,closedList) || isBlocked(s,obstacleRow,obstacleCol)){
        cout<<"Node is invalid\n\n"<<endl;
      }
      else {
        cout<<"Adding node to open list..."<<endl;
        openList.push_back(node()); 
        cout<<"Filling new node..."<<endl;
        openList[openList.size()-1].i = s.i;
        openList[openList.size()-1].j = s.j;
        openList[openList.size()-1].g = s.g;
        openList[openList.size()-1].h = s.h;
        openList[openList.size()-1].f = s.f;

        cout<<"Successor node is valid, adding to open list"<<endl;
        cout<<"Total cost of successor node is "<<s.f<<endl;
        cout<<"Open list has "<<openList.size()<<" elements\n"<<endl;
      }
    }

    closedList.push_back(q);
    
    cout<<"Closed list has "<<closedList.size()<<" elements\n"<<endl;
    cout<<"Open list has "<<openList.size()<<" elements\n"<<endl;
  }
  cout<<"Path Planning has Completed"<<endl;
  return;
}

void pathPlanning::reverseSearch(vector<node> &closedList,vector<node> &waypoints){
  cout<<"Beginning reverse search!"<<endl;
  node t;
  t.i = closedList.back().i;
  t.j = closedList.back().j;
  t.g = closedList.back().g;
  closedList.pop_back();
  waypoints.push_back(t);
  cout<<"Starting g cost is "<<t.g<<endl;
  double tempG = t.g;
  int tempI = 0;
  int tempJ = 0;

  while(closedList.size()!=0){
    tempI = 0;
    tempJ = 0;

    for(int k=0;k<8;k++){
      node s;

      s = genSuccessor(t,k);

      // search closed list for node s
      if(!((s.i < 0) || (s.i > 20) || (s.j < 0) || (s.j > 60))){
        for(int z=closedList.size()-1;z>=0;z--){ 
          cout<<"Searching closed list...."<<endl;
          cout<<"Successor is ("<<s.i<<","<<s.j<<")"<<endl;
          cout<<"Closed list check is ("<<closedList[z].i<<","<<closedList[z].j<<")"<<endl;
          if(s.i == closedList[z].i && s.j == closedList[z].j){
            cout<<"Node is in closed list"<<endl;
            s.g = closedList[z].g;
            cout<<"Node g cost is "<<s.g<<endl;
            if(s.g < tempG){
              cout<<"Found a lower g cost"<<endl;
              tempG = s.g;
              tempI = s.i;
              tempJ = s.j;
            }
            cout<<"TempG is "<<tempG<<" TempI is "<<tempI<<" TempJ is "<<tempJ<<endl;
            break;
          }
        }
      }else{continue;}
      
      if(tempI == 1 && tempJ == 1){
        t.i = tempI;
        t.j = tempJ;
        t.g = tempG;

        waypoints.push_back(t);

        cout<<"Shortest path found\n\n"<<endl;
        for(int q=waypoints.size()-1;q>=0;q--){
          cout<<"Step: "<<q<<" Row: "<<waypoints[q].i<< " Col: "<<waypoints[q].j<<endl;
        }
        return;
      }
    }

    t.i = tempI;
    t.j = tempJ;
    t.g = tempG;

    cout<<"\n\n NEWEST WAYPOINT IS ("<<tempI<<","<<tempJ<<")"<<endl;

    waypoints.push_back(t);
  }
}


pathPlanning::~pathPlanning()
{}