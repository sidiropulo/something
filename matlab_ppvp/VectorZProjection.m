function VectorZProjection = VectorZProjection(beta,gamma,k,x,y)
    beta_rad = deg2rad(beta); 
    gamma_rad = deg2rad(gamma); 
    
    a = 1;
    b = cos(beta_rad)*sin(gamma_rad);
    c = sin(beta_rad)*sin(gamma_rad);
    
    divider = cos(gamma_rad);
    
    VectorZProjection = (a*k+b*x+c*y)/divider;
end

