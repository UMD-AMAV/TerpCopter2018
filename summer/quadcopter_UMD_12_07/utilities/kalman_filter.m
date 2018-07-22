function S_hat_future = kalman_filter(S_measured,S_hat,gain)
 %BASIC KALMAN FILTER  
S_hat_future = S_hat + gain.*(S_measured - S_hat); 

%     L_1 = 0.4;
%     L_2 =0.4;
%     L_3 =0.4;    
%     S_hat_future(1) = S_hat(1) + L_1 * (S_measured(1) - S_hat(1));  %L_1 is gain
%     S_hat(1) =  S_hat_future(1);
%     
%     S_hat_future(2) = S_hat(2) + L_2 * (S_measured(2) - S_hat(2));  %L_2 is gain
%     S_hat(2) =  S_hat_future(2);
%     
%     S_hat_future(3) = S_hat(3) + L_3 * (S_measured(3) - S_hat(3));  %L_3 is gain
%     S_hat(3) =  S_hat_future(3);
       
end