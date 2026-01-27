function minutes = timeStringtoMinutes(timeString)

    dtv = datevec(datetime(timeString, "InputFormat","HH:mm"));
    dur = duration(dtv(:, 4:end));
    minutes = time2num(dur, "minutes");
end