 %Function myWait waits for the duration that is input in seconds.
   function myWait(duration)
        start = GetSecs;
        while true
            if GetSecs - start > duration
                break;
            end
        end
    end