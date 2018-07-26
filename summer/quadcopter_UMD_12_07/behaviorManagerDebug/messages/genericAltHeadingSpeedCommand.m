function [ahsCmd] = genericAltHeadingSpeedCommand()
ahsCmd = struct;

ahsCmd.altitude.setpointMeters = 0.0;
ahsCmd.altitude.outerLoopKp = 0.0;
ahsCmd.altitude.Kp = 0.0;
ahsCmd.altitude.Kd = 0.0;
ahsCmd.altitude.Ki = 0.0;

ahsCmd.heading.setpointRad = 0.0;
ahsCmd.heading.Kp = 0.0;
ahsCmd.heading.Kd = 0.0;
ahsCmd.heading.Ki = 0.0;

ahsCmd.forwardSpeed.setpointMps = 0.0;
ahsCmd.forwardSpeed.Kp = 0.0;
ahsCmd.forwardSpeed.Kd = 0.0;
ahsCmd.forwardSpeed.Ki = 0.0;

ahsCmd.crabSpeed.setpointMps = 0.0;
ahsCmd.crabSpeed.Kp = 0.0;
ahsCmd.crabSpeed.Kd = 0.0;
ahsCmd.crabSpeed.Ki = 0.0;
end

