[filepath,name,ext] = fileparts(mfilename('fullpath'));
cd(filepath);
cd('..');
files = dir(filepath);

mfiledir = fullfile('adi');
docdir = fullfile('doc');

rootClasses = {...
    {'AD9081',{'Rx','Tx'}},...
    {'AD9083',{'Rx'}},...
    {'AD9084',{'Rx','Tx'}},...
    {'AD9144',{'Tx'}},...
    {'AD9152',{'Tx'}},...
    {'AD9213',{'Rx'}},...
    {'DualAD9213',{'Rx'}},...
    {'AD9467',{'Rx'}},...
    {'AD9680',{'Rx'}},...
    {'DAQ2',{'Rx','Tx'}},...
    {'DAQ3',{'Rx','Tx'}},...
    {'QuadMxFE',{'Rx','Tx'}}...
    };

all_devs = [];
for ii = 1:numel(rootClasses)
    for jj = 1:numel(rootClasses{ii}{2})
        part = rootClasses{ii}{1};
        tmp = rootClasses{ii}{2};
        trx_file = tmp{jj};
        all_props = [];
        dotmfilename = strcat(mfiledir, '.', part, '.', trx_file);
        props = properties(dotmfilename);
        for prop = 1:length(props)

            if props{prop} == "enIO"
                continue;
            end
            pdoc = help(strcat(dotmfilename,'.',props{prop}));
            
            pdocs = strsplit(pdoc,'\n');
            prop_title = pdocs{1};
            prop_description = strip(replace(strjoin(pdocs(2:end),'\n'),'\n',''));
            prop_description = int32(prop_description);
            prop_description(prop_description==10) = [];
            prop_description(prop_description==13) = [];
            prop_description = char(prop_description);
            prop_description = replace(prop_description,'    ',' ');
            prop_description = replace(prop_description,'  ',' ');
            
            s = struct('prop_name',props{prop},...
                'prop_title',prop_title,...
                'prop_description',prop_description);
            all_props = [all_props,s];
        end
        top_doc = help(dotmfilename);
        top_doc = strsplit(top_doc,'\n');
        top_doc = replace(top_doc,'\n','<br>');
        top_doc = strjoin(top_doc(2:end),'<br>');

%         top_doc = strip(replace(top_doc,'\n',''));
%         top_doc = int32(top_doc);
%         top_doc(top_doc==10) = [];
%         top_doc(top_doc==13) = [];
%         top_doc = char(top_doc);
%         top_doc = replace(top_doc,'    ',' ');
%         top_doc = replace(top_doc,'  ',' ');

        
        oname = struct('name',dotmfilename, 'dec',top_doc, 'props',all_props);
        all_devs = [all_devs, oname];
    end
end
%%
jsonText = jsonencode(all_devs,'PrettyPrint',true);
fid = fopen('docs/sysobjs.json', 'w');
fprintf(fid, '%s', jsonText);
fclose(fid);

