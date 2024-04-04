function [FoundDevices] = GetDevicesByModelName(deviceModelName)
    % Перезагружаем DAQ (при повторном получении списка устройств
    % daq.getDevices() возвращает данные из своего класса, которые 
    % были сохранены в него при первом запуске)
    daqreset;
    all_devices=daq.getDevices();

    FoundDevices = all_devices(strcmp(all_devices.Model,deviceModelName));
end