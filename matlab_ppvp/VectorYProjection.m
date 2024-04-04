function VectorYProjection = VectorYProjection(beta,gamma, k,x,z)
    beta_rad = deg2rad(beta); 
    gamma_rad = deg2rad(gamma); 
    
    a = - 1;
    b = -cos(beta_rad)*sin(gamma_rad);
    c = cos(gamma_rad);
    
    divider  = sin(beta_rad)*sin(gamma_rad);
    
    VectorYProjection = (a*k+b*x+c*z)/ divider;
end

