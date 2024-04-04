function [FoundDevice] = GetDeviceById(deviceId)
    % ������������� DAQ (��� ��������� ��������� ������ ���������
    % daq.getDevices() ���������� ������ �� ������ ������, ������� 
    % ���� ��������� � ���� ��� ������ �������)
    daqreset;
    devices=daq.getDevices();

    found_device_idx = find(strcmp(devices.ID,deviceId), 1);
    FoundDevice = devices(found_device_idx);
end