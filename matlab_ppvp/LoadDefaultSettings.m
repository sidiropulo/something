function Settings = LoadDefaultSettings()
 file=xmlread('DefaultSettings.xml');
 settings_root = file.getElementsByTagName('Settings').item(0);
 
 device_root = settings_root.getElementsByTagName('Device').item(0);
 Settings.Device.ModelName = string(device_root.getElementsByTagName('ModelName').item(0).getFirstChild().getData());
 Settings.Device.SamplingFrequency = str2double(device_root.getElementsByTagName('SamplingFrequency').item(0).getFirstChild().getData());
 Settings.Device.DataUpdate = str2double(device_root.getElementsByTagName('DataUpdate').item(0).getFirstChild().getData());
 
 filter_root = settings_root.getElementsByTagName('Filter').item(0);
 Settings.Filter.LowerCutoffFrequency = str2double(filter_root.getElementsByTagName('LowerCutoffFrequency').item(0).getFirstChild().getData());
 Settings.Filter.UpperCutoffFrequency = str2double(filter_root.getElementsByTagName('UpperCutoffFrequency').item(0).getFirstChild().getData());
 
 working_frequency_band_root = settings_root.getElementsByTagName('WorkingFrequencyBand').item(0);
 Settings.WorkingFrequencyBand.Center = str2double(working_frequency_band_root.getElementsByTagName('Center').item(0).getFirstChild().getData());
 Settings.WorkingFrequencyBand.Radius = str2double(working_frequency_band_root.getElementsByTagName('Radius').item(0).getFirstChild().getData());
 
 Settings.ModulPermissibleMaxDeviation = str2double(settings_root.getElementsByTagName('ModulPermissibleMaxDeviation').item(0).getFirstChild().getData());
 
 axis_angle_root = settings_root.getElementsByTagName('AxisAngle').item(0);
 Settings.AxisAngle.Beta = str2double(axis_angle_root.getElementsByTagName('Beta').item(0).getFirstChild().getData());
 Settings.AxisAngle.Gamma = str2double(axis_angle_root.getElementsByTagName('Gamma').item(0).getFirstChild().getData());
 
 transmission_factor_root = settings_root.getElementsByTagName('TransmissionFactor').item(0);
 Settings.TransmissionFactor.X = str2double(transmission_factor_root.getElementsByTagName('X').item(0).getFirstChild().getData());
 Settings.TransmissionFactor.Y = str2double(transmission_factor_root.getElementsByTagName('Y').item(0).getFirstChild().getData());
 Settings.TransmissionFactor.Z = str2double(transmission_factor_root.getElementsByTagName('Z').item(0).getFirstChild().getData());
 Settings.TransmissionFactor.K = str2double(transmission_factor_root.getElementsByTagName('K').item(0).getFirstChild().getData());
 
 Settings.Decimator = str2double(settings_root.getElementsByTagName('Decimator').item(0).getFirstChild().getData());
 Settings.FrequencyDelta = str2double(settings_root.getElementsByTagName('FrequencyDelta').item(0).getFirstChild().getData());
 
 Settings.SignificanceThreshold = str2double(settings_root.getElementsByTagName('SignificanceThreshold').item(0).getFirstChild().getData());
 
 Settings.ProjectionPermissibleMaxDeviation = str2double(settings_root.getElementsByTagName('ProjectionPermissibleMaxDeviation').item(0).getFirstChild().getData());
end

