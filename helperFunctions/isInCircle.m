function isInside = isInCircle(x, y, mCircle, rCircle)
% Check whether given point (x,y) is in Circle

% Distance Point to Middle of Circle
dx = abs(x - mCircle(1));
dy = abs(y - mCircle(2));

if (dx^2 + dy^2 < rCircle^2)
    isInside = true;
else
    isInside = false;
end

end