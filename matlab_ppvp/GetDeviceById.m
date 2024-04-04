function [FoundDevice] = GetDeviceById(deviceId)
    % Перезагружаем DAQ (при повторном получении списка устройств
    % daq.getDevices() возвращает данные из своего класса, которые 
    % были сохранены в него при первом запуске)
    daqreset;
    devices=daq.getDevices();

    found_device_idx = find(strcmp(devices.ID,deviceId), 1);
    FoundDevice = devices(found_device_idx);
end