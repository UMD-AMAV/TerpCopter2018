function Z_hat = kalman_altitude(Z_measured,Z_hat)
   
    L = 0.4;
    
    Z_hat_future = Z_hat + L * (Z_measured - Z_hat);  %L is gain
    
    Z_hat =  Z_hat_future;
       
end