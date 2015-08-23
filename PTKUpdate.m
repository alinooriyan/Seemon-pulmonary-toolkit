function updated = PTKUpdate(varargin)
    % PTKUpdate. A script to update the PTK codebase via git
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2015.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    updated = false;
    if checkDoNotUpdate && ~(nargin > 0 && strcmp(varargin{1}, 'force'))
        disp('Ignoring updates as requested by user.');
    else
        clearDoNotUpdate;
        full_path = mfilename('fullpath');
        [rootSourceDir, ~, ~] = fileparts(full_path);
        [rootSourceDir, ~, ~] = fileparts(rootSourceDir);
        repoList = DepMatRepo('pulmonarytoolkit', 'master', 'https://github.com/tomdoel/pulmonarytoolkit.git', 'pulmonarytoolkit');
        depMat = DepMat(repoList, rootSourceDir);
        status = depMat.getAllStatus;
    
        if ~isMasterBranch
            disp('! Cannot check for updates as the master branch is not checked out');
        else
            switch status
                case DepMatStatus.GitNotFound
                    disp('! Cannot check for updates as git could not be found');
                case DepMatStatus.DirectoryNotFound
                    disp('! Cannot check for updates as the repository could not be found');
                case DepMatStatus.NotUnderSourceControl
                    disp('! Cannot check for updates as this repository does not appear to be under git source control');
                case DepMatStatus.FetchFailure
                    disp('! Cannot check for updates because a failure occurred previously during fetch. Pleaes fix the repository and delete the depmat_fetch_failure file.');
                case DepMatStatus.UpToDate
                case {DepMatStatus.UpdateAvailable, DepMatStatus.LocalChanges}
                    answer = questdlg('A new version of PTK is available. Do you wish to update PTK?','Pulmonary Toolkit','Later','Do not ask me again', 'Update','Update');
                    if strcmp(answer, 'Do not ask me again')
                        setDoNotUpdateFlag
                    elseif strcmp(answer, 'Update')
                        if depMat.updateAll;
                            updated = true;
                        end
                    end
                case DepMatStatus.Conflict
                    disp('! An update is available but this would cause a conflict. Please update and merge manually.');
                case DepMatStatus.GitFailure
                    disp('! Cannot check for updates because a git command failed to execute.');
            end
        end
    end
end

function setDoNotUpdateFlag
    full_path = mfilename('fullpath');
    [path_root, ~, ~] = fileparts(full_path);    
    filename = fullfile(path_root, 'do-not-update-git');
    fileHandle = fopen(filename, 'w');
    fclose(fileHandle);
end

function doNotUpdate = checkDoNotUpdate
    full_path = mfilename('fullpath');
    [path_root, ~, ~] = fileparts(full_path);
    filename = fullfile(path_root, 'do-not-update-git');
    doNotUpdate = (2 == exist(filename, 'file'));
end

function clearDoNotUpdate
    full_path = mfilename('fullpath');
    [path_root, ~, ~] = fileparts(full_path);
    filename = fullfile(path_root, 'do-not-update-git');
    if (2 == exist(filename, 'file'))
        delete(filename);
    end
end

function repoExists = isMasterBranch
    [success, branch] = DepMat.execute('git rev-parse --symbolic-full-name --abbrev-ref HEAD');
    branch = strtrim(branch);
    repoExists = success && strcmp(branch, 'master');
end


