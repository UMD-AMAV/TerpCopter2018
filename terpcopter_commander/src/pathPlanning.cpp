#include <pathPlanning.h>

using namespace std;

struct node {
  node();
  int i,j;
  double g,h,f;
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
  bool valid = true; // heap search
    for(int k=openList.size()-1;k>=0;k--){
      if(openList[k].i == nd.i && openList[k].j == nd.j){
        valid = false;
      }
    }
    for(int z=closedList.size()-1;z>=0;z--){
      if(closedList[z].i == nd.i && openList[z].j == nd.j){
        valid = false;
      }
    }
  return ((nd.i > 0) && (nd.i < ROW) && (nd.j > 0) && (nd.j < COL) && valid);
  }

bool pathPlanning::isGoal(node nd){
  return (nd.i == TI && nd.j == TJ);
}

bool pathPlanning::isBlocked(node nd, vector<int> &obstacleRow, vector<int> &obstacleCol){
  for(int k=0;k<obstacleCol.size();k++){
    if(nd.i == obstacleCol[k] && nd.j == obstacleRow[k]){
      return true;
    }
  }
  return false;
}

double pathPlanning::calcH(node nd){
  return sqrt(10.0*(pow(TI-nd.i,2)+pow(TJ-nd.j,2))); // not quite right for euclidena dist heuristic
}

void pathPlanning::mapToLoc(vector<int> &map, vector<int> &obstacleRow,
    vector<int> &obstacleCol){
  for(int i=0;i<map.size();i++){
    if(map[i]!= 0){
      obstacleCol.push_back((i+1)%COL);
      obstacleRow.push_back((i+1)/COL+1); // make sure this is integer division
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
  cout<<"Successor Node row is "<<s.i<<" successor node column is "<<s.j<<endl;
  return s;
}

void pathPlanning::aStarPlan(int c_i, int c_j, vector<node> &closedList){
  vector<node> openList;
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
    cout<<"Origin Node row is "<<q.i<<" origin node column is "<<q.j<<"\n\n"<<endl;
    openList.erase(openList.begin()+idx-1);

    for(int i=0;i<8;i++){
      node s; //create node, fill it and then
      s = genSuccessor(q,i);

      if(isGoal(s)){
        closedList.push_back(s);
        cout<<"Goal Reached!"<<endl;
        return;
      }
      else if(!isValid(s,openList,closedList)){
        cout<<"Node is invalid\n\n"<<endl;
      }
      else {
        openList.push_back(node());
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

pathPlanning::~pathPlanning()
{}