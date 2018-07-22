function V_HAT_FUTURE = get_forward_crab_speed_estimate(V_HAT,ACC,ACC_PREV,dt)
persistent counterAccX counterAccY;
if isempty(V_HAT),V_HAT = [0;0]; end
if isempty(ACC_PREV),V_HAT_FUTURE = V_HAT; return; end
if isempty(counterAccX), counterAccX = 0; end
if isempty(counterAccY), counterAccY = 0; end
velCurrX = V_HAT(1);
velCurrY = V_HAT(2);
AccX = ACC(1);
AccY = ACC(2);
prevAccX = ACC_PREV(1);
prevAccY = ACC_PREV(2);

%Calculate Current Velocity (m/s)
leakRateAcc = 0.99000;
velCurrX = velCurrX*leakRateAcc + ( prevAccX + (AccX-prevAccX)/2 ) * dt;
velCurrY = velCurrY*leakRateAcc + ( prevAccY + (AccY-prevAccY)/2 ) * dt;

%Discrimination window for Acceleration
if ((0.12 > AccX) && (AccX > -0.12))
  AccX = 0;
end

if ((0.12 > AccY) && (AccY > -0.12))
  AccY = 0;
end

%Count number of times acceleration is equal to zero to drive velocity to zero when acceleration is "zero"
%X-axis---------------
if (AccX == 0)
    %Increment no of times AccX is = to 0 
    counterAccX = counterAccX+1;    
else
    %Reset counter
    counterAccX = 0;
end

if (counterAccX>15)
    %Drive Velocity to Zero
    velCurrX = 0;
    %prevVelX = 0;
    counterAccX = 0;
end

%Y-axis--------------
if (AccY == 0)
    %Increment no of times AccY is = to 
    counterAccY = counterAccY+1;    
else
    %Reset counter
    counterAccY = 0;
end

if (counterAccY>15)
    %Drive Velocity to Zero
    velCurrY = 0;
    %prevVelY = 0;
    counterAccY = 0;
end

V_HAT_FUTURE = [velCurrX;velCurrY];

% //Print Acceleration and Velocity
% cout << " AccX = " << AccX ;// << endl;
% cout << " AccY = " << AccY ;// << endl;
% cout << " AccZ = " << AccZ << endl;
% 
% cout << " velCurrX = " << velCurrX ;// << endl;
% cout << " velCurrY = " << velCurrY ;// << endl;
% cout << " velCurrZ = " << velCurrZ << endl;
% 
% //Calculate Current Position in Meters
% float leakRateVel = 0.99000;
% posCurrX = posCurrX*leakRateVel + ( prevVelX + (velCurrX-prevVelX)/2 ) * dt;
% posCurrY = posCurrY*leakRateVel + ( prevVelY + (velCurrY-prevVelY)/2 ) * dt;
% posCurrZ = posCurrZ*0.99000 + ( prevVelZ + (velCurrZ-prevVelZ)/2 ) * dt;
% prevVelX = velCurrX;
% prevVelY = velCurrY;
% prevVelZ = velCurrZ;
% 
% //Print X and Y position in meters
% cout << " posCurrX = " << posCurrX ;// << endl;
% cout << " posCurrY = " << posCurrY ;// << endl;
% cout << " posCurrZ = " << posCurrZ << endl;
% 
end