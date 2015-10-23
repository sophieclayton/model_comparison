function a = set(a,varargin)

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   propName = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   eval(['a.' propName '=val;']);
end

