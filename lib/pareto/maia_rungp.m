data_port = sqrt(imu_data_aligned.IMU5.signal_surge.^2 + imu_data_aligned.IMU5.signal_sway.^2).*1.33;
data_sb = sqrt(imu_data_aligned.IMU4.signal_surge.^2 + imu_data_aligned.IMU4.signal_sway.^2);

timevect = imu_data_aligned.IMU5.matdatenum;

windowlength = 3000;
frequency = 100;
threshold = 0.10;

[gp_port] = maia_recursivegp(data_port,timevect,windowlength,threshold,frequency);
[gp_sb] = maia_recursivegp(data_sb,timevect,windowlength,threshold,frequency);

function [gp] = maia_recursivegp(data,timevect,windowlength,threshold,frequency)

L = length(data);

gp.windowlength = windowlength;
gp.frequency = frequency;
gp.threshold = threshold;
%blockmax = zeros(L,);
gp.estimate = zeros(L,2);
gp.CIdown = zeros(L,2);
gp.CIup = zeros(L,2);
gp.matdatenum = timevect;
%mleevSEs = zeros(L,3);

for k = 1+windowlength:1:L
    
    if mod(k,1000) == 0
    k    
    end
    
    datawindow = data(k-windowlength:k);
    gp.exceedances(k,:) = length(datawindow(datawindow>threshold));
    
    if gp.exceedances(k,:) > 0
        [gptemp,gpCItemp] = gpfit(datawindow(datawindow>threshold)-threshold);
        
    else
        gptemp = [NaN NaN];
        gpCItemp = [NaN NaN; NaN NaN];
    end
        
    gp.estimate(k,:) = gptemp;
        gp.CIdown(k,:) = gpCItemp(1,:);
        gp.CIup(k,:) = gpCItemp(2,:);
end

end