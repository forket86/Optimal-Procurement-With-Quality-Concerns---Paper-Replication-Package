if 1 % get file name, say hello
    [~, thisFileName, ~] = fileparts(mfilename('fullpath'));
    thisLpName = strrep(thisFileName, 'fn_', '');
    fprintf('\n-----------------------------------')
    fprintf('\nvvv from %s:  vvvvvv',...
        thisFileName)
end

thisScriptFolder = pwd;

if 1 % create subfolder and move in it
    if 1 % make subfolder for output files
        if 1 % make dateTimeString
            ecco = clock;
            dateTimeString = num2str(ecco(1));
            dateTimeString = [dateTimeString '-' num2str(ecco(2))];
            dateTimeString = [dateTimeString '-' num2str(ecco(3))];
            dateTimeString = [dateTimeString '_' num2str(ecco(4))];
            dateTimeString = [dateTimeString '-' num2str(ecco(5))];
        end
        subFolderName = [dateTimeString '_' thisFileName];
    end
    mkdir([desktopFolder subFolderName]);
    fprintf('\n   New subfolder %s created', subFolderName)
    cd([desktopFolder subFolderName]);
    fprintf('\n   we now are inside the folder %s', subFolderName)
end

if 1 % solve the LP
    if 0 % write AMPL's .MOD file
        modFileName = [thisLpName '.mod'];
        fid = fopen(modFileName, 'wt');
        if 1 % parameters
            fprintf(fid,'# --- Parameters ----');
            fprintf(fid,'\n param T; # num of Cost values ');
            fprintf(fid,'\n param S; # num of Suppliers ');
            fprintf(fid,'\n param D; # to rescale Q ');
            fprintf(fid,'\n param f {1..T};');
            fprintf(fid,'\n param F {1..T};');
            fprintf(fid,'\n param c {1..T};');
            fprintf(fid,'\n param w {1..T};');
            fprintf(fid,'\n');
        end
        if 1 % variables
            fprintf(fid,'\n# --- Decision variables ----');
            fprintf(fid,'\n var Q {1..T}; ');
            fprintf(fid,'\n');
        end
        
        if 1 % objective function
            fprintf(fid,'\n# --- LP ----');
            fprintf(fid,'\n maximize O_BUYER_SURPLUS:');
            fprintf(fid,'\n sum{t in 1..T} (f[t]*w[t]*Q[t]);');
            %fprintf(fid,'\n ');
        end
        if 1 % constraints
            if 1 % BorderDemandConstraint
                fprintf(fid,'\n\n subject to BorderDemandConstraint {t in 1..T}:');
                fprintf(fid,'\n sum{k in 1..t} (Q[k]*f[k]) <= D*(1-(1-F[t])^S)/S;');
            end
            if 1 % Non Negativity
                fprintf(fid,'\n\n subject to QNonNegT:');
                fprintf(fid,'\n -Q[T] <= 0;');
            end
            if 1 % qMon
                fprintf(fid,'\n\n subject to QMon {t in 1..T-1}:');
                fprintf(fid,'\n - Q[t] + Q[t+1] <= 0;');
            end
        end
        fclose(fid);
        fprintf('\n    ''%s'' (text file) written', modFileName)
        
    end
    if 0 % write AMPL's .DAT file
        datFileName = [thisLpName '.dat'];
        fid = fopen(datFileName, 'wt');
        if 1 % write parameters
            
            fprintf(fid,'param T = %d;\n\n', T);
            fprintf(fid,'param S = %d;\n\n', S);
            fprintf(fid,'param D = %d;\n\n', 1);
            if 1 % w
                fprintf(fid,'param w = \r\n');
                fprintf(fid,'\t');
                for t = 1:T
                    fprintf(fid,'%d\t', t);
                    fprintf(fid,'%.9f\r\n\t', w(t));
                end
                fprintf(fid,';\r\n\r\n');
            end
            
            if 1 % cost grid
                fprintf(fid,'param c = \r\n');
                fprintf(fid,'\t');
                for t = 1:T
                    fprintf(fid,'%d\t', t);
                    fprintf(fid,'%.9f\r\n\t', c(t));
                end
                fprintf(fid,';\r\n\r\n');
            end
            
            if 1 % f
                fprintf(fid,'param f = \r\n');
                fprintf(fid,'\t');
                for t = 1:T
                    fprintf(fid,'%d\t', t);
                    fprintf(fid,'%.9f\r\n\t', f(t));
                end
                fprintf(fid,';\r\n\r\n');
            end
            
            if 1 % F_marginal
                fprintf(fid,'param F = \r\n');
                fprintf(fid,'\t');
                for t = 1:T
                    fprintf(fid,'%d\t', t);
                    fprintf(fid,'%.9f\r\n\t', F(t));
                end
                fprintf(fid,';\r\n\r\n');
            end
            
        end
        fclose(fid);
        fprintf('\n    ''%s'' (text file) written', datFileName)
    end
    if 1 % write AMPL's .RUN file
        runFileName = [thisLpName '.run'];
        fid = fopen(runFileName, 'wt');
        if 1 % write: load .mod and .dat
            fprintf(fid,'# --- Load .mod and .dat ----\n');
            fprintf(fid,'reset;\n');
            fprintf(fid,'model %s;\n', modFileName);
            fprintf(fid,'data %s;\n', datFileName);
            fprintf(fid,'\n');
        end
        
        
        if 1 % write: call Cplex
            fprintf(fid,'# --- call CPLEX ----\n');
            fprintf(fid,'option solver ''%s'';\n', [cplexPath 'cplexamp']);
            fprintf(fid,'solve;\n\n');
        end
        if 1 % write: Store LP Value and optimal solution in .txt files
            fprintf(fid,'# --- Store optimal solution in .txt files --- \n');
            fprintf(fid,'print{i in 1..T1, j in 1..T2}: q_1[i,j] > q_1_out.txt;\n');
            fprintf(fid,'close q_1_out.txt;\n\n');
            fprintf(fid,'print{i in 1..T1, j in 1..T2}: q_2[i,j] > q_2_out.txt;\n');
            fprintf(fid,'close q_2_out.txt;\n\n');
        end
        if 1 % close .run file
            fclose(fid);
        end
        fprintf('\n    ''%s'' (text file) written', runFileName)
    end
    if 1 % system call: feed .RUN file to AMPL
        fprintf('\n\nSolving the given LP %s with CPLEX ... \n', thisLpName)
        system([amplPath 'ampl ' runFileName]);
        fprintf('CPLEX is done.\n')
    end
    if 1 % Load:  LP_Value, Q, M (function output)
        fprintf('\n  Loading CPLEX output in Matlab ... ')
        load q_1_out.txt;
        q_1 = q_1_out;
        fprintf('\n   %s loaded', 'q_1')
        load q_2_out.txt;
        q_2 = q_2_out;
        fprintf('\n   %s loaded', 'q_2')
        fprintf('\n   ... done.')
    end
    if 1
        q_1_opt = reshape(q_1,costGridSize2,costGridSize1)';
        q_2_opt = reshape(q_2,costGridSize2,costGridSize1)';
    end 
end



if 1 % final report
    fprintf('\n\n^^^ %s is done ^^^^^^ ', thisFileName)
    fprintf('\n------------------------------------\n')
end

