function Printallinstructions()
% Writeallscripts();

filename='UCM.m'; %'UCM.m', 'SVS.m', 'UCMal.m'

fid = fopen(filename);

nocases=0;
currentcase=''; %this should never be used
while (true)
    
    tline = fgetl(fid);
    
    if ( (numel(tline)==1) && (tline==-1) )
%         fprintf('End of file reached\n');
        break;
    end
    
    if ( (numel(tline)>3) && (strcmp(tline(1:3),'%%%')) ) %three % denote a new case name
        currentcase=tline(4:end);
        
        %fprintf('mmv -c "%s/gtimages/*Defm.dat" "%s/gtimages/#1Defmf.dat"\n',currentcase,currentcase); %nowrp 
        fprintf('./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "%s"\n',currentcase); %nowrp
        %fprintf('cp -rf ./Videopicsidx_mns_0d0008p ./%s/\n',currentcase); %nowrp
        
        nocases=nocases+1;
    end
    
end
fclose(fid);

fprintf('No cases written %d\n',nocases);


% ssh submit-lenny
% source /n1_grid/current/inf/common/settings.sh
% dos2unix Allscripts123       _This removes all ^M from scripts
% echo "mcc -R -singleCompThread -m Ucmscript123.m -v -a ./ ; quit" | /usr/bin/matlab -nojvm -nosplash -nodisplay

% Modify run_Ucmscript123.sh to include output capture

% ./run_Ucmscript123.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Syntheticai"

% Modify Allscripts123 to execute the compiled command run_Ucmscript123

% commands2arrayjob.sh Allscripts123 -l h_rt=168::
% commands2arrayjob.sh Allscripts123
% /BS/amin-project/work/submit/commands2arrayjob.sh Allscripts123 -l h_rt=168::

% cd ~/.mcrCache7.14/
% cd Cluste1/
% ls -lah
% qstat
% qstat -u "*"
% qstat -g c



%Copy instructions for BVDS+PD people
% cp -rf ./Videopicsidx_mns_0d0008p ./Razonasototer/
% cp -rf ./Videopicsidx_mns_0d0008p ./Razonasevenbis/
% cp -rf ./Videopicsidx_mns_0d0008p ./Shinagawafive/
% cp -rf ./Videopicsidx_mns_0d0008p ./Shinagawafourthbis/
% cp -rf ./Videopicsidx_mns_0d0008p ./Razonaeightbis/
% cp -rf ./Videopicsidx_mns_0d0008p ./Syntheticai/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpletwo/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplefive/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplethirteen/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpleone/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplethree/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplefour/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplesix/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpleseven/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpleeight/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marplenine/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpleten/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpleeleven/
% cp -rf ./Videopicsidx_mns_0d0008p ./Marpletwelve/
% cp -rf ./Videopicsidx_mns_0d0008p ./Tennis/
% cp -rf ./Videopicsidx_mns_0d0008p ./Peopleone/
% cp -rf ./Videopicsidx_mns_0d0008p ./Peopletwo/

%Copy instructions for BVDS
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Syntheticai/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpletwo/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplefive/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplethirteen/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsfour/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpleone/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplethree/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplefour/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplesix/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpleseven/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpleeight/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marplenine/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpleten/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpleeleven/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Marpletwelve/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Tennis/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Peopleone/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Peopletwo/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsone/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carstwo/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsthree/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsfive/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carssix/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsseven/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carseight/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsnine/
% cp -rf ./Videopicsidx_mns_bm0d0008p ./Carsten/

%All runscript cases
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonasototer"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonasevenbis"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawafive"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawafourthbis"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonaeightbis"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Syntheticai"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonasix"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonaseven"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonaeight"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonasoto"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawafirst"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawasecond"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawathird"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonasotobis"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Razonaten"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Shinagawafourth"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpletwo"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplefive"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplethirteen"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsfour"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpleone"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplethree"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplefour"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplesix"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpleseven"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpleeight"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marplenine"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpleten"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpleeleven"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Marpletwelve"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Tennis"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Peopleone"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Peopletwo"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsone"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carstwo"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsthree"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsfive"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carssix"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsseven"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carseight"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsnine"
% ./run_Ucmscript.sh /BS/opt/local/MATLAB_Compiler_Runtime/v714 "Carsten"


%All BVDS
% mmv -c "Marpletwo/gtimages/*Defm.dat" "Marpletwo/gtimages/#1Defmf.dat"
% mmv -c "Marplefive/gtimages/*Defm.dat" "Marplefive/gtimages/#1Defmf.dat"
% mmv -c "Marplethirteen/gtimages/*Defm.dat" "Marplethirteen/gtimages/#1Defmf.dat"
% mmv -c "Carsfour/gtimages/*Defm.dat" "Carsfour/gtimages/#1Defmf.dat"
% mmv -c "Marpleone/gtimages/*Defm.dat" "Marpleone/gtimages/#1Defmf.dat"
% mmv -c "Marplethree/gtimages/*Defm.dat" "Marplethree/gtimages/#1Defmf.dat"
% mmv -c "Marplefour/gtimages/*Defm.dat" "Marplefour/gtimages/#1Defmf.dat"
% mmv -c "Marplesix/gtimages/*Defm.dat" "Marplesix/gtimages/#1Defmf.dat"
% mmv -c "Marpleseven/gtimages/*Defm.dat" "Marpleseven/gtimages/#1Defmf.dat"
% mmv -c "Marpleeight/gtimages/*Defm.dat" "Marpleeight/gtimages/#1Defmf.dat"
% mmv -c "Marplenine/gtimages/*Defm.dat" "Marplenine/gtimages/#1Defmf.dat"
% mmv -c "Marpleten/gtimages/*Defm.dat" "Marpleten/gtimages/#1Defmf.dat"
% mmv -c "Marpleeleven/gtimages/*Defm.dat" "Marpleeleven/gtimages/#1Defmf.dat"
% mmv -c "Marpletwelve/gtimages/*Defm.dat" "Marpletwelve/gtimages/#1Defmf.dat"
% mmv -c "Tennis/gtimages/*Defm.dat" "Tennis/gtimages/#1Defmf.dat"
% mmv -c "Peopleone/gtimages/*Defm.dat" "Peopleone/gtimages/#1Defmf.dat"
% mmv -c "Peopletwo/gtimages/*Defm.dat" "Peopletwo/gtimages/#1Defmf.dat"
% mmv -c "Carsone/gtimages/*Defm.dat" "Carsone/gtimages/#1Defmf.dat"
% mmv -c "Carstwo/gtimages/*Defm.dat" "Carstwo/gtimages/#1Defmf.dat"
% mmv -c "Carsthree/gtimages/*Defm.dat" "Carsthree/gtimages/#1Defmf.dat"
% mmv -c "Carsfive/gtimages/*Defm.dat" "Carsfive/gtimages/#1Defmf.dat"
% mmv -c "Carssix/gtimages/*Defm.dat" "Carssix/gtimages/#1Defmf.dat"
% mmv -c "Carsseven/gtimages/*Defm.dat" "Carsseven/gtimages/#1Defmf.dat"
% mmv -c "Carseight/gtimages/*Defm.dat" "Carseight/gtimages/#1Defmf.dat"
% mmv -c "Carsnine/gtimages/*Defm.dat" "Carsnine/gtimages/#1Defmf.dat"
% mmv -c "Carsten/gtimages/*Defm.dat" "Carsten/gtimages/#1Defmf.dat"
