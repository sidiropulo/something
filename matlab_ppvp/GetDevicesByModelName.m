function [FoundDevices] = GetDevicesByModelName(deviceModelName)
    % ������������� DAQ (��� ��������� ��������� ������ ���������
    % daq.getDevices() ���������� ������ �� ������ ������, ������� 
    % ���� ��������� � ���� ��� ������ �������)
    daqreset;
    all_devices=daq.getDevices();

    FoundDevices = all_devices(strcmp(all_devices.Model,deviceModelName));
end