function IsPreferences = IsPreferences(preferences)
    if ~isstruct(preferences)
       IsPreferences = false;
       return;
    end
    
    if ~isfield(preferences,'WorkingFrequencyBand')
       IsPreferences = false;
       return;
    end    
    working_frequency_band = preferences.WorkingFrequencyBand;
    
    if ~(isfield(working_frequency_band,'Radius') ...
            && isa(working_frequency_band.Radius, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(working_frequency_band,'Center') ...
            && isa(working_frequency_band.Center, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~isfield(preferences,'TransmissionFactor')
       IsPreferences = false;
       return;
    end    
    transmission_factors = preferences.TransmissionFactor;
    
    if ~(isfield(transmission_factors,'X') ...
            && isa(transmission_factors.X, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'Y') ...
            && isa(transmission_factors.Y, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'Z') ...
            && isa(transmission_factors.Z, 'double'))
       IsPreferences = false;
       return;
    end
    
    if ~(isfield(transmission_factors,'K') ...
            && isa(transmission_factors.K, 'double'))
       IsPreferences = false;
       return;
    end
    
     if ~(isfield(preferences,'ModulPermissibleMaxDeviation') ...
            && isa(preferences.ModulPermissibleMaxDeviation, 'double'))
       IsPreferences = false;
       return;
     end
     
     if ~(isfield(preferences,'SignificanceThreshold') ...
            && isa(preferences.SignificanceThreshold, 'double'))
       IsPreferences = false;
       return;
     end
     
     if ~(isfield(preferences,'ProjectionPermissibleMaxDeviation') ...
            && isa(preferences.ProjectionPermissibleMaxDeviation, 'double'))
       IsPreferences = false;
       return;
     end

    IsPreferences = true;
end