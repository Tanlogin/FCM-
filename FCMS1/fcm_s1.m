function [u,v,step_num] =fcm_s1(image_data,init_v,window_size,cluster_num,m,min_distance,alpha,max_step);
% the algorithm FCM_S1

% initialize the parameter
[image_row,image_col]=size(image_data);
image_pixel_num=image_row*image_col;
image_vect=reshape(image_data,image_pixel_num,1);
step_num=0;

% pre_u: the previous cluster memberships of the pixels; u: the cluster memberships of the pixels
% pre_v: the previous cluster centers of the pixels; v: the cluster centers of the pixels
pre_u=zeros(image_pixel_num,cluster_num);
pre_v=init_v;
v=zeros(1,cluster_num);               
u=zeros(image_pixel_num,cluster_num); 

% compute the mean-filtered image
image_filter = colfilt(image_data,[window_size window_size],'sliding',@filter1);   % row*col 
image_filter_vect = reshape(image_filter,image_pixel_num,1);
while(1)
    
    % computer the cluster membership u
    for i=1:cluster_num
        u_cluster_i = ((image_vect-repmat(pre_v(1,i),image_pixel_num,1)).^2+alpha.*(image_filter_vect-repmat(pre_v(1,i),image_pixel_num,1)).^2);
        u_cluster_i(find(u_cluster_i<=0.000000001))=0.000000001;
        u_cluster_i= u_cluster_i.^(-1/(m-1));                 % u(:,i):q*1  u:q*cluster_num
        u(:,i)=reshape(u_cluster_i,image_pixel_num,1);
    end;
    u_sum=sum(u,2);
    u=u./repmat(u_sum,1,cluster_num);
    
    % computer the cluster centers v
    v_numerator=u.^m.*(repmat(image_vect,1,cluster_num)+alpha.*repmat(image_filter_vect,1,cluster_num)); 
    v_numerator=sum(v_numerator,1);
    v_denominator=u.^m;
    v_denominator=(1+alpha).*sum(v_denominator,1);
    v_denominator(find(v_denominator<=0.000000001))=0.000000001;
    v=v_numerator./v_denominator;
    
    % if the cluster membership u and the cluster centers v are not changed, the algorithm stops  
    if (norm(pre_u-u)<min_distance)&&(norm(pre_v-v)<min_distance)
        fprintf('v=%f',v);
        fprintf('step_num=%d',step_num);
        break;
    else        
        pre_u=u;
        pre_v=v;         
        step_num=step_num+1;
    end;     
   
     % if the iterative step equals max_step, the algorithm also stops  
    if step_num>max_step
        fprintf('the loop time is exceed!');
        break;       
    end;        
end;