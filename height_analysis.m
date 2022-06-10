function varargout = height_analysis(varargin)
% HEIGHT_ANALYSIS M-file for height_analysis.fig
%      HEIGHT_ANALYSIS, by itself, creates a new HEIGHT_ANALYSIS or raises the existing
%      singleton*.
%
%      H = HEIGHT_ANALYSIS returns the handle to a new HEIGHT_ANALYSIS or the handle to
%      the existing singleton*.
%
%      HEIGHT_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEIGHT_ANALYSIS.M with the given input arguments.
%
%      HEIGHT_ANALYSIS('Property','Value',...) creates a new HEIGHT_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before height_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to height_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help height_analysis

% Last Modified by GUIDE v2.5 09-Dec-2009 13:02:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @height_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @height_analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before height_analysis is made visible.
function height_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to height_analysis (see VARARGIN)

% Choose default command line output for height_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes height_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global ha;

ha = [];

%default settings
ha.def_directory = '';
ha.def_wildcard = '*.jpg';
% ha.def_threshold = 0.5;
% ha.def_minint = 80;
ha.def_minwid = 4;
ha.def_medfilt = [5 3];
ha.def_scale = 1;
ha.def_flip = 0;
ha.def_name = 'report1.txt';
ha.def_channel = 1;
ha.max_channel = 1;

set(handles.dir_box, 'String' ,ha.def_directory);
set(handles.wildcard_box, 'String', ha.def_wildcard);
set(handles.name_box, 'String', ha.def_name);

ha.curr_idx = -1;
ha.curr_channel = 1;
ha.files = {};
draw_image(handles);


% --- Outputs from this function are returned to the command line.
function varargout = height_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function draw_image(handles)
global ha;


%if no files, clear axes and set default values
if(isempty(ha.files)||ha.curr_idx<1)


    %set(handles.thresh_box, 'String', sprintf('%g', ha.def_threshold));
    %set(handles.thresh_slide, 'Value',ha.def_threshold);
    %set(handles.minint_box, 'String', sprintf('%u', ha.def_minint));
    %set(handles.minint_slide, 'Value',ha.def_minint);
    set(handles.minwid_box, 'String', sprintf('%d', ha.def_minwid));
    set(handles.minwid_slide, 'Value',ha.def_minwid);
    set(handles.medfilt_box, 'String', sprintf('%d %d', ha.def_medfilt));
    set(handles.info_text, 'String', ' ');
    set(handles.flip_check, 'Value', ha.def_flip);
    set(handles.scale_box, 'String', sprintf('%g', ha.def_scale));
    
    axes(handles.axes1);
    cla;
    axis off;
    set(handles.info_text,'String',' ');
    
    axes(handles.axes2);
    cla;
    axis off;
    axis tight;
    return;
end

%set current values
if ha.is_done(ha.curr_channel,ha.curr_idx) %if done, use previously assigned values
    update_parameters(handles, ha.curr_idx, ha.curr_channel)
else 
    update_parameters(handles, ha.prev_idx, ha.prev_channel)
end
ha.prev_idx=ha.curr_idx;
a=update_image(ha.curr_idx, get(handles.dir_box,'String'), get(handles.disp_check,'Value'),ha.curr_channel);


axes(handles.axes1);
cla;
imshow(ha.I,[]);
title([get(handles.dir_box,'String') ha.files{ha.curr_idx}],'Interpreter','none');
set(handles.info_text, 'String', sprintf('Mean: %g Median: %g StdDev: %g Min: %g Max: %g',...
    ha.cmean(ha.curr_channel,ha.curr_idx), ha.cmed(ha.curr_channel,ha.curr_idx),...
    ha.cdev(ha.curr_channel,ha.curr_idx), ha.cmin(ha.curr_channel,ha.curr_idx),...
    ha.cmax(ha.curr_channel,ha.curr_idx)));

axes(handles.axes2);
cla;
%plot(ha.max_ints{ha.curr_idx});
plot(ha.heights{ha.curr_channel,ha.curr_idx});
v = axis;
axis([1 size(a,2) v(3:4)]);

function a=update_image(idx, path, do_disp, channel)
global ha;

ha.is_done(channel,idx) = 1;

asdf = imread([path ha.files{idx}]);

if(isnan(ha.upperlim(channel,idx)))
    ha.upperlim(channel,idx) = size(asdf,1);
end

if(ndims(asdf)==3)
%     b=a(:,:,1);
%     b(a(:,:,2)~=0)=0;
%     a=b;
%     clear b;
    a=asdf(:,:,channel);
else
    if(channel==1)
        a=asdf;
    else
        a=zeros(size(asdf));
    end
    asdf = cat(3,asdf,zeros(size(asdf)),zeros(size(asdf)));
end

if(ha.flip(idx))
    a = flipud(a);
    for i=1:size(asdf,3)
        asdf(:,:,i) = flipud(asdf(:,:,i));
    end
end

a = medfilt2(a,ha.medfilt(idx,:));

ha.heights{channel,idx} = zeros(1,size(a,2));
ha.max_ints{channel,idx} = zeros(1,size(a,2));

b = zeros(size(a),'uint8');
% min_int = ha.minint(channel,idx);
min_wid = ha.minwid(channel,idx);
% thr = ha.threshold(channel,idx);
for i=1:size(a,2)
    l = a(:,i);

%         [pks,locs] = findpeaks(l,'minpeakheight',min_int, 'minpeakdistance',...
%             min_wid,'sortstr','none');
%         pks


    [m1 idx1] = max(l(ha.lowerlim(channel,idx):ha.upperlim(channel,idx)));
    idx1 = idx1+ha.lowerlim(channel,idx)-1;
    %skip if less than minimum intensity
%     if(m1<min_int)
%         continue;
%     end
    
    %old version
    %thr = thr*m1;
    %new version
    thr = 0.5*mean(l(idx1-3:idx1+3));
    
    %start at max intensity and work until you reach upper limit or
    % you drop below a threshold
    j = idx1;
    while j<=length(l)
        if(l(j)<thr)
            break;
        end
        peak_end = j;
        j=j+1;
        if(j>ha.upperlim(channel,idx))
            break;
        end
    end

    %lower
    j = idx1;
    while j>0
        if(l(j)<thr)
            break;
        end
        peak_start = j;
        j=j-1;
        if(j<ha.lowerlim(channel,idx))
            break;
        end
    end

    
    ha.heights{channel,idx}(i) = peak_end - peak_start + 1;
    if(ha.heights{channel,idx}(i)<min_wid)
        ha.heights{channel,idx}(i) = 0;
    else
        b(peak_start:peak_end,i) = 255;
        ha.max_ints{channel,idx}(i) = m1;
    end
end

if(numel(a)~=numel(b))
    save debug_matfile.mat
    error('weird error about to occur');
end
if(do_disp)
    ha.I = cat(3,asdf(:,:,1),asdf(:,:,2),b);
    for i=-1:1
        ha.I(min(max(ha.lowerlim(channel,idx)+i,1),size(ha.I,1)),:,3) = 255*ones(1,size(ha.I,2));
        ha.I(min(max(ha.upperlim(channel,idx)+i,1),size(ha.I,1)),:,3) = 255*ones(1,size(ha.I,2));
    end
else
    ha.I = asdf;
end

t = ha.heights{channel,idx}(ha.heights{channel,idx}~=0);

if(isempty(t))
    ha.cmean(channel,idx) = 0;
    ha.cmed(channel,idx) = 0;
    ha.cmin(channel,idx) = 0;
    ha.cmax(channel,idx) = 0;
    ha.cdev(channel,idx) = Inf;
else    
    ha.cmean(channel,idx) = ha.scale(idx)*mean(t);
    ha.cmed(channel,idx) = ha.scale(idx)*median(t);
    ha.cmin(channel,idx) = ha.scale(idx)*min(t);
    ha.cmax(channel,idx) = ha.scale(idx)*max(t);
    ha.cdev(channel,idx) = ha.scale(idx)*std(t);
end

function update_parameters(handles, idx, channel)
global ha;
if(idx<0)
    %set(handles.thresh_box, 'String', sprintf('%g', ha.def_threshold));
    %set(handles.thresh_slide, 'Value',ha.def_threshold);
    %set(handles.minint_box, 'String', sprintf('%u', ha.def_minint));
    %set(handles.minint_slide, 'Value',ha.def_minint);
    set(handles.minwid_box, 'String', sprintf('%d', ha.def_minwid));
    set(handles.minwid_slide, 'Value',ha.def_minwid);
    set(handles.medfilt_box, 'String', sprintf('%d %d', ha.def_medfilt));
    set(handles.info_text, 'String', ' ');
    set(handles.flip_check, 'Value', ha.def_flip);
    set(handles.scale_box, 'String', sprintf('%g', ha.def_scale));
    set(handles.channel_menu, 'Value', ha.def_channel);
    
    set(handles.lowerlim_slide, 'Min', 1);
    set(handles.lowerlim_slide, 'Max', 512);
    set(handles.lowerlim_slide, 'Value', 512);
    set(handles.upperlim_slide, 'Min', 1);
    set(handles.upperlim_slide, 'Max', 512);
    set(handles.upperlim_slide, 'Value', 1);
else
    %set(handles.thresh_box, 'String', sprintf('%g', ha.threshold(channel,idx)));
    %set(handles.thresh_slide, 'Value',ha.threshold(channel,idx));
    %set(handles.minint_box, 'String', sprintf('%d', ha.minint(channel,idx)));
    %set(handles.minint_slide, 'Value',ha.minint(channel,idx));
    set(handles.minwid_box, 'String', sprintf('%d', ha.minwid(channel,idx)));
    set(handles.minwid_slide, 'Value',ha.minwid(channel,idx));
    set(handles.medfilt_box, 'String', sprintf('%d %d', ha.medfilt(idx,:)));
    set(handles.scale_box, 'String', sprintf('%g', ha.scale(idx)));
    set(handles.flip_check, 'Value', ha.flip(idx));
    set(handles.channel_menu, 'Value', channel);
    
    if(ha.lowerlim(channel,idx)>ha.upperlim(channel,idx))
        ha.upperlim(channel,idx)=ha.lowerlim(channel,idx);
    end
    set(handles.lowerlim_slide, 'Min', 1);
    set(handles.lowerlim_slide, 'Max', size(ha.I,1));
    set(handles.lowerlim_slide, 'Value', get(handles.lowerlim_slide,'Max')-ha.lowerlim(channel,idx)+1);
    set(handles.upperlim_slide, 'Min', 1);
    set(handles.upperlim_slide, 'Max', size(ha.I,1));
    set(handles.upperlim_slide, 'Value', get(handles.upperlim_slide,'Max')-ha.upperlim(channel,idx)+1);
    
    %copy parameters from last image viewed
    ha.upperlim(ha.curr_channel,ha.curr_idx) = ha.upperlim(channel,idx);
    ha.lowerlim(ha.curr_channel,ha.curr_idx) = ha.lowerlim(channel,idx);
    %ha.threshold(ha.curr_channel,ha.curr_idx) = ha.threshold(channel,idx);
    %ha.minint(ha.curr_channel,ha.curr_idx) = ha.minint(channel,idx);
    ha.minwid(ha.curr_channel,ha.curr_idx) = ha.minwid(channel,idx);
    ha.medfilt(ha.curr_idx,:) = ha.medfilt(idx,:);
    ha.flip(ha.curr_idx) = ha.flip(idx);
    ha.scale(ha.curr_idx) = ha.scale(idx);
end


function write_report(path,filename)
global ha;
fid=fopen([path filename],'w');
fprintf(fid,'Filename   Channel Mean(um) Median(um) Std.Dev.(um) Min.(um) Max.(um) Threshold Min.Int. Filter  Scale\n');
for j=1:ha.max_channel
    for i=1:length(ha.files)
%         fprintf(fid,'%-12s %-6d %-8g %-10g %-12g %-8g %-8g %-9g %-8g [%-2d %-2d] %-8g\n',...
%             ha.files{i},j, ha.cmean(j,i), ha.cmed(j,i), ha.cdev(j,i),...
%             ha.cmin(j,i), ha.cmax(j,i), ha.threshold(j,i), ha.minint(j,i),...
%             ha.medfilt(i,1), ha.medfilt(i,2), ha.scale(i));
        fprintf(fid,'%-12s %-6d %-8g %-10g %-12g %-8g %-8g [%-2d %-2d] %-8g\n',...
            ha.files{i},j, ha.cmean(j,i), ha.cmed(j,i), ha.cdev(j,i),...
            ha.cmin(j,i), ha.cmax(j,i),...
            ha.medfilt(i,1), ha.medfilt(i,2), ha.scale(i));

    end
end

fclose(fid);


function dir_box_Callback(hObject, eventdata, handles)  %#ok<*INUSD,*DEFNU>
function wildcard_box_Callback(hObject, eventdata, handles)
function name_box_Callback(hObject, eventdata, handles)

function thresh_box_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.threshold(ha.curr_channel, ha.curr_idx) = str2double(get(hObject,'String'));
    if(isnan(ha.threshold(ha.curr_channel, ha.curr_idx)) || ha.threshold(ha.curr_channel, ha.curr_idx)<=0 || ...
            ha.threshold(ha.curr_channel, ha.curr_idx)>=1)
        ha.threshold(ha.curr_channel, ha.curr_idx) = ha.def_threshold;
    end
end
draw_image(handles);

% function minint_box_Callback(hObject, eventdata, handles)
% global ha;
% if(ha.curr_idx>0)
%     ha.minint(ha.curr_channel, ha.curr_idx) = round(str2double(get(hObject,'String')));
%     if(isnan(ha.minint(ha.curr_channel, ha.curr_idx)) || ha.minint(ha.curr_channel, ha.curr_idx)<0 ||...
%         ha.minint(ha.curr_channel, ha.curr_idx)>255)
%         ha.minint(ha.curr_channel, ha.curr_idx) = ha.def_minint;
%     end
% end
% draw_image(handles);

function minwid_box_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.minwid(ha.curr_channel, ha.curr_idx) = round(str2double(get(hObject,'String')));
    if(isnan(ha.minwid(ha.curr_channel, ha.curr_idx)) || ha.minwid(ha.curr_channel, ha.curr_idx)<=0)
        ha.minwid(ha.curr_channel, ha.curr_idx) = ha.def_minwid;
    end
end
draw_image(handles);

function medfilt_box_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    v = str2num(get(hObject,'String'));
    if(length(v)<2 || any(isnan(v)) || any(v<0))
        v = ha.def_medfilt;
    end
    v = v(1:2);
    ha.medfilt(ha.curr_channel, ha.curr_idx,:)=v;
end
draw_image(handles);

function flip_check_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.flip(ha.curr_idx) = get(hObject,'Value');
end
draw_image(handles);

function prev_butt_Callback(hObject, eventdata, handles)
global ha;
ha.prev_channel = ha.curr_channel;
ha.curr_idx = ha.curr_idx - 1;
if(ha.curr_idx<1)
    ha.curr_idx = length(ha.files);
end
draw_image(handles);

function next_butt_Callback(hObject, eventdata, handles)
global ha;
ha.prev_channel = ha.curr_channel;
ha.prev_idx = ha.curr_idx;
ha.curr_idx = ha.curr_idx + 1;
if(ha.curr_idx>length(ha.files))
    ha.curr_idx = 1;
end

draw_image(handles);

function read_butt_Callback(hObject, eventdata, handles)
global ha;
ha.curr_idx = -1;
ha.prev_idx = -1;
ha.curr_channel = 1;
ha.prev_channel = 1;
f = dir([get(handles.dir_box,'String') get(handles.wildcard_box,'String')]);
ha.files = {f.name};
if ~isempty(ha.files)
    ha.curr_idx = 1;
%     ha.threshold = ones(ha.max_channel,length(ha.files))*ha.def_threshold;
%     ha.minint = ones(ha.max_channel,length(ha.files))*ha.def_minint;
    ha.minwid = ones(ha.max_channel,length(ha.files))*ha.def_minwid;
    ha.medfilt = repmat(ha.def_medfilt,[length(ha.files),1]);
    ha.scale = ones(1,length(ha.files))*ha.def_scale;
    ha.flip = ones(1,length(ha.files))*ha.def_flip;
    
    ha.heights = cell(ha.max_channel,length(ha.files));
    ha.peak_start = cell(ha.max_channel,length(ha.files));
    ha.max_ints = cell(ha.max_channel,length(ha.files));
    
    ha.lowerlim = ones(ha.max_channel,length(ha.files));
    ha.upperlim = ones(ha.max_channel,length(ha.files))*nan;
    
    ha.cmean = zeros(ha.max_channel,length(ha.files));
    ha.cmed = zeros(ha.max_channel,length(ha.files));
    ha.cmin = zeros(ha.max_channel,length(ha.files));
    ha.cmax = zeros(ha.max_channel,length(ha.files));
    ha.cdev = zeros(ha.max_channel,length(ha.files));
    ha.is_done = zeros(ha.max_channel,length(ha.files));
end

draw_image(handles);

function done_butt_Callback(hObject, eventdata, handles)
global ha;

if(isempty(ha.files))
    return;
end

%handle not reviewed case
if(~all(all(ha.is_done)))
    s = sprintf('The following files were not reviewed.  Default settings used.\n');
    for i=1:length(ha.files)
        for j=1:ha.max_channel
            if(~ha.is_done(j,i))
                s = [s sprintf('%s(%d)\n',ha.files{i},j)];
            end
        end
    end
    
    warndlg(s,'Warning','modal');
end

%update unreviewed images
path = get(handles.dir_box,'String');
do_disp = get(handles.disp_check,'Value');
for i=1:length(ha.files)
    for j=1:ha.max_channel
        if(ha.is_done(j,i))
            continue;
        end
        update_image(i, path, do_disp, j);
    end
    
end

write_report(get(handles.dir_box,'String'),get(handles.name_box,'String'));

function disp_check_Callback(hObject, eventdata, handles)
draw_image(handles);

function scale_box_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.scale(ha.curr_idx) = str2double(get(hObject,'String'));
    if(isnan(ha.scale(ha.curr_idx)) || ha.scale(ha.curr_idx)<=0)
        ha.scale(ha.curr_idx) = ha.def_scale;
    end
end
draw_image(handles);

% function minint_slide_Callback(hObject, eventdata, handles)
% global ha;
% if(ha.curr_idx>0)
%     ha.minint(ha.curr_channel, ha.curr_idx) = round(get(hObject,'Value'));
% end
% draw_image(handles);

function minwid_slide_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.minwid(ha.curr_channel,ha.curr_idx) = round(get(hObject,'Value'));
end
draw_image(handles);

function thresh_slide_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.threshold(ha.curr_channel,ha.curr_idx) = get(hObject,'Value');
end
draw_image(handles);

function lowerlim_slide_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.lowerlim(ha.curr_channel,ha.curr_idx) = get(hObject,'Max')-round(get(hObject,'Value'))+1;
end
draw_image(handles);

function upperlim_slide_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.upperlim(ha.curr_channel,ha.curr_idx) = get(hObject,'Max')-round(get(hObject,'Value'))+1;
end
draw_image(handles);

function channel_menu_Callback(hObject, eventdata, handles)
global ha;
if(ha.curr_idx>0)
    ha.prev_channel = ha.curr_channel
    ha.curr_channel = get(hObject,'Value');
end
draw_image(handles);

function dir_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function wildcard_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wildcard_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function thresh_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function minint_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minint_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function minwid_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minwid_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function medfilt_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medfilt_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function scale_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function minint_slide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minint_slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function name_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function thresh_slide_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function minwid_slide_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function lowerlim_slide_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function upperlim_slide_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function channel_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








