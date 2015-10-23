function a = subsasgn(a,index,val)

switch index(1).type
case '{}'
   if length(index)>1;
      aa=subsref(a,index(1)); val=subsasgn(aa,index(2:end),val);
   end;

   nFaces=get(a,'nFaces');
   iFace=index(1).subs{:};
   if iFace<=nFaces&iFace>0;
      eval(['a.f' num2str(iFace) '=val;']);
   else
      error('Index out of range')
   end
case '.'
   if length(index)>1;
      aa=subsref(a,index(1)); val=subsasgn(aa,index(2:end),val);
   end;

   a=set(a,index(1).subs,val);
case '()'
   if length(index)>1; error('indexing not supported by gcmfaces objects'); end;   

   for iFace=1:a.nFaces; iF=num2str(iFace);
      if isa(index.subs{1},'gcmfaces');
         if isa(val,'gcmfaces');
            eval(['a.f' iF '(index.subs{1}.f' iF ')=val.f' iF ';']);
         else;
            eval(['a.f' iF '(index.subs{1}.f' iF ')=val;']);
         end;
      else;
         if isa(val,'gcmfaces');
            eval(['a.f' iF '=subsasgn(a.f' iF ',index,val.f' iF ');']);
         else;
            eval(['a.f' iF '=subsasgn(a.f' iF ',index,val);']);
         end;
      end;
   end;
otherwise
   error('indexing not supported by gcmfaces objects')
end

%if length(index)>1; b=subsref(b,index(2:end)); end;

