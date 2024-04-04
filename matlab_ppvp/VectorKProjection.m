function VectorKProjection = VectorKProjection(beta,gamma,x,y,z)
    beta_rad = deg2rad(beta); 
    gamma_rad = deg2rad(gamma); 
    
    a = -cos(beta_rad)*sin(gamma_rad);
    b = -sin(beta_rad)*sin(gamma_rad);
    c = cos(gamma_rad);
    
    VectorKProjection = a*x+b*y+c*z;
end


