function demo()
% the main function

clear;

% read the image data;
image_data=double(imread('tu2.jpg'));
image_data=image_data./255;
image_data=image_data(:,:,1);
[image_row,image_col] = size(image_data);

% the setting of the experiment
q=255;                        % q: the number of the gray levels;
m=1.75;                          % m: a weighting exponent on each fuzzy membership that determines the amount of fuzziness of the resulting classification;
max_step=100;                 % max_step: the maximum iterative step;
min_distance=0.0001;         % min_distance: the samll value; 
cluster_num=2;                % cluster_num: the number of the clusters; 
init_v=rand(1,cluster_num);   % init_v: the initial values of the cluster centers;

% set the values of the parameters
alpha=8;                      % alpha: control the effect of the neighbors term in FCM_S1, FCM_S2 and EnFCM
window_size=3;                % window_size: the size of the local window;  
gray_scale=2;                 % gray_scale: denotes the global scale factor of the spread of Sg_ij
spatial_scale=3;              % spatial_scale: denotes the scale factor of the spread of Ss_ij

for bMethod=1:6,
     % bMethod ==1: FCM_S1;   bMethod ==2: FCM_S2;   bMethod ==3: EnFCM; 
     % bMethod ==4: FGFCM_S1; bMethod ==5: FGFCM_S2; bMethod ==6: FGFCM; 
    if bMethod==1    
        tic;
t1=clock
        [u,v,step_num] =fcm_s1(image_data,init_v,window_size,cluster_num,m,min_distance,alpha,max_step);  
        tic;
        t2=clock;
fcms1=clock;
etime(t2,t1)
    elseif bMethod==2  
        tic;
t1=clock
        [u,v,step_num] =fcm_s2(image_data,init_v,window_size,cluster_num,m,min_distance,alpha,max_step);
        tic;
t2=clock;
fcms2=etime(t2,t1)
    elseif bMethod==3  
        tic;
t1=clock
        % first compute a linearly-weighted sum image, then perform fast fcm on this image
        linearly_weighted_filter_image = colfilt(image_data,[window_size window_size],'sliding',@linearly_weighted_filter,alpha);
        [u,v,step_num] =fast_fcm(linearly_weighted_filter_image,init_v,cluster_num,m,min_distance,max_step,q);    
        tic;
t2=clock;
en=etime(t2,t1)
    elseif bMethod==4   
        tic;
t1=clock
        % first compute a mean filter image, then perform fast fcm on this image
        mean_filter_image = colfilt(image_data,[window_size window_size],'sliding',@mean);  
        [u,v,step_num] =fast_fcm(mean_filter_image,init_v,cluster_num,m,min_distance,max_step,q); 
        tic;
t2=clock;
FGFCMS1=etime(t2,t1)
    elseif bMethod==5    
        tic;
t1=clock
        % first compute a median filter image, then perform fast fcm on this image
        median_filter_image = colfilt(image_data,[window_size window_size],'sliding',@median);  %
        [u,v,step_num] =fast_fcm( median_filter_image,init_v,cluster_num,m,min_distance,max_step,q); 
        t2=clock;
FGFCMS2=etime(t2,t1)
    elseif bMethod==6 
        tic;
t1=clock
        % first compute a Sij-generated image, then perform fast fcm on this image
        s_filter_image = colfilt(image_data,[window_size window_size],'sliding',@s_filter,gray_scale,spatial_scale);
        [u,v,step_num] =fast_fcm(s_filter_image,init_v,cluster_num,m,min_distance,max_step,q);
        t2=clock;
fGFCM=etime(t2,t1);
    end
   
    % compute the cluster labels for the pixels  
    [sort_v index_v]=sort(v);
    sort_u=u(:,index_v);
    [max_u,max_u_index]=max(sort_u');
    cluster_label=col2im(max_u_index,[1 1],[image_row image_col]);
    cluster_label=cluster_label-1;
    cluster_label = cluster_label(1:image_row-1,1:image_col-1);
  num=0;
    % show the segmentation image
    cluster_image=zeros(image_row-1,image_col-1);
    for i=1:cluster_num
        cluster_image(find(cluster_label==(i-1)))=sort_v(1,i);
        %count=sum(cluster_label==(i-1))
        num=sum(sum(cluster_label==(i-1)))
        %count=count+1;
    end;
    %count
    cluster_show_image=zeros(image_row-1,image_col-1);
   cluster_show_image(find(cluster_label==0))=0;
   cluster_show_image(find(cluster_label==1))=120;
    cluster_show_image=cluster_label/(cluster_num-1)*0.8;
    imwrite(cluster_show_image,'2.jpg');
    figure;imshow(cluster_show_image,'Border','tight' );  
end;