[filepath,name,ext] = fileparts(mfilename('fullpath'));
cd(filepath);
files = dir(filepath);

target = '../../../doc/sim/ad9081';

skip = {'NA'};

for f = {files.name}
    if strfind(f{:},'.mlx')>=0
        filename = f{:};
%         if ~contains(filename,'top_level')
%             continue;
%         end
        if contains(filename,skip)
            continue;
        end
        htmlFilename = [filename(1:end-4),'.html'];
        pdfFilename = [filename(1:end-4),'.pdf'];
        disp(htmlFilename);
        matlab.internal.liveeditor.openAndConvert(filename,htmlFilename);
%         matlab.internal.liveeditor.openAndConvert(filename,pdfFilename);
%         continue;
        
        text = fileread(htmlFilename);
        % Update links to point to internal doc
        % Assume doc links are of forum: hsxdocroot/adc.html
        dr = 'hsxdocroot_ad9081';
        updated = false;
        while(1)
%             break
            o = strfind(text,dr);
            if isempty(o)
                break;
            end
            ss = text(o(1)+length(dr)+1:end);
            % Find end of link
%             s = 'html">';
            s = 'html"';
            e = findstr(ss,s);
            if isempty(e)
                continue;
            end
            updated = true;
            e = findstr(ss,s)+length(s)-2;
            ss = ss(1:e);
            ns = sprintf("matlab:web([docroot '/3ptoolbox/analogdevicesinchighspeedconvertertoolboxtoolbox/doc/sim/ad9081/%s'])",ss);
            text = char(strrep(text,['hsxdocroot_ad9081/',ss],ns));
        end
        if updated
            fileID = fopen(htmlFilename,'w');
            nbytes = fprintf(fileID,'%s',text);
            fclose(fileID);
        end
        
        movefile(htmlFilename,target);
    end
end
