function [Session] = CreateSession(targetDeviceParams, isContinuous)
   found_devices = GetDevicesByModelName(targetDeviceParams.ModelName);
   if numel(found_devices) == 0
        throw(MException('CreateSession:DeviceNotFoundByModelName',...
                    'Устройство имеющее наименование модели %s не найдено.',targetDeviceParams.ModelName)); 
   end
   
   target_device = found_devices(end);
   
   Session = daq.createSession('ni');
   
%    Session.addAnalogInputChannel(target_device.ID,'ai0','Accelerometer');
%    Session.addAnalogInputChannel(target_device.ID,'ai1','Accelerometer'); 
%    Session.addAnalogInputChannel(target_device.ID,'ai2','Accelerometer');
%    Session.addAnalogInputChannel(target_device.ID,'ai3','Accelerometer');
%    Session.Channels(1).Sensitivity = 1;
%    Session.Channels(2).Sensitivity = 1;
%    Session.Channels(3).Sensitivity = 1;
%    Session.Channels(4).Sensitivity = 1;
%   
%    Session.Channels(1,1,1,1).InputType ='PseudoDifferential';
   
   Session.addAnalogInputChannel(target_device.ID,'ai0','Voltage');
   Session.addAnalogInputChannel(target_device.ID,'ai1','Voltage'); 
   Session.addAnalogInputChannel(target_device.ID,'ai2','Voltage');
   Session.addAnalogInputChannel(target_device.ID,'ai3','Voltage');
   Session.Channels(1,1,1,1).InputType ='PseudoDifferential';
   
   Session.IsContinuous = isContinuous;
   SetSamplingFrequency(Session, targetDeviceParams.SamplingFrequency);
   
   Session.NotifyWhenDataAvailableExceeds = Session.Rate*targetDeviceParams.DataUpdate;
end

