function VectorXProjection = VectorXProjection(beta,gamma, k,y,z)
    beta_rad = deg2rad(beta); 
    gamma_rad = deg2rad(gamma); 
    
    a = - 1;
    b = -sin(beta_rad)*sin(gamma_rad);
    c = cos(gamma_rad);
    
    divider  = cos(beta_rad)*sin(gamma_rad);
    
    VectorXProjection = (a*k+b*y+c*z)/ divider;
end