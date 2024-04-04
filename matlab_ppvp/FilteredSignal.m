function FilteredSignal = FilteredSignal(signal, samplingFrequency, filter)
    FilteredSignal = LowpassButterworthFilter(signal,samplingFrequency,filter.UpperCutoffFrequency);
    FilteredSignal = HighpassButterworthFilter(FilteredSignal,samplingFrequency,filter.LowerCutoffFrequency);
end

