function minutes = timeStringtoMinutes(timeString)
 % pass in an array of time strings in format HH:mm with 24 hour time
 % return equivalently sized array of time in minutes, assuming 00:00 is 0
    dtv = datevec(datetime(timeString, "InputFormat","HH:mm"));
    dur = duration(dtv(:, 4:end));
    minutes = time2num(dur, "minutes");
end