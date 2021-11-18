function PromptHandle=ZachPrompt(Message,MessageTitle,GoodIcon)
    if ~isempty(GoodIcon)
        if ispc
            userDir = winqueryreg('HKEY_CURRENT_USER',...
                ['Software\Microsoft\Windows\CurrentVersion\' ...
                 'Explorer\Shell Folders'],'Personal');
             dc='\';
        else
            userDir = char(java.lang.System.getProperty('user.home'));
            dc='/';
        end
        Thumbnail=[];
        ThumbNailDir=[userDir,dc,'MATLAB',dc,'Zachs Functions',dc,'Interface Tools',dc,'Thumbnails',dc];
        switch GoodIcon
            case 1
                if exist([ThumbNailDir,'Matlab Good.jpeg'])
                    Thumbnail = imread([ThumbNailDir,'Matlab Good.jpeg']);
                    Thumbnail=imrotate(Thumbnail,270);
                else
                    Thumbnail=[];
                end
            case 0
                if exist([ThumbNailDir,'Matlab Bad.jpeg'])
                    Thumbnail = imread([ThumbNailDir,'Matlab Bad.jpeg']);
                    Thumbnail=imrotate(Thumbnail,270);
                else
                    Thumbnail=[];
                end
            case 2
                if exist([ThumbNailDir,'Matlab Positive.jpeg'])
                    Thumbnail = imread([ThumbNailDir,'Matlab Positive.jpeg']);
                    %Thumbnail=imrotate(Thumbnail,270);
                else
                    Thumbnail=[];
                end
        end
        if ~isempty(Thumbnail)
            PromptHandle=msgbox(Message,MessageTitle,'custom',Thumbnail);
        else
            PromptHandle=msgbox(Message,MessageTitle);
        end
    else
        PromptHandle=msgbox(Message,MessageTitle);
    end
end



