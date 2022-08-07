if 1 % get file name, say hello
    [~, thisFileName, ~] = fileparts(mfilename('fullpath'));
    thisLpName = strrep(thisFileName, 'fn_', '');
    
    fprintf('\nvvvvvvvvv  from %s:  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n',...
        thisFileName)
    
    fprintf('\ncL = %0.2f ', cL)
    fprintf('\ncH = %0.2f ', cH)
    
    fprintf('\n')
    
end

Local=pwd;

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
    
    mkdir([root subFolderName]);
    fprintf('\nNew subfolder %s created', subFolderName)
    cd([root subFolderName]);
    fprintf('\nWe now are inside %s', subFolderName)
end

if 1 % solve the LP
    if 1 % write AMPL's .MOD file
        modFileName = [thisLpName '.mod'];
        fid = fopen(modFileName, 'wt');
        if 1 % parameters
            fprintf(fid,'# --- Parameters ----\n');
            fprintf(fid,'param T; # num of Cost values \n');
            fprintf(fid,'param fc {1..T,1..T};\n');
            fprintf(fid,'param c {1..T};\n');
            fprintf(fid,'param w {1..T,1..T};\n');
            fprintf(fid,'\n');
        end
        if 1 % variables
            fprintf(fid,'# --- Decision variables ----\n');
            fprintf(fid,'var q {1..T,1..T}; \n');
            fprintf(fid,'\n');
        end
        
        if 1 % objective function
            fprintf(fid,'# --- LP ----\n');
            fprintf(fid,'maximize O_BUYER_SURPLUS:\n');
            fprintf(fid,'sum{c1_ind in 1..T, c2_ind in 1..T}\n');
            fprintf(fid,' (fc[c1_ind,c2_ind]*w[c1_ind,c2_ind]*q[c1_ind,c2_ind]);\n\n');
        end
        if 1 % constraints
            if 1 % DemandConstraint
                fprintf(fid,'subject to DemandConstraint {c1_ind in 1..T, c2_ind in 1..T : c1_ind <= c2_ind}:\n');
                fprintf(fid,'q[c1_ind,c2_ind] + q[c2_ind,c1_ind] <= 1;\n\n');
            end
            if 1 % Non Negativity
                fprintf(fid,'subject to qNonNeg {c2_ind in 1..T}:\n');
                fprintf(fid,'-q[T,c2_ind]<=0;\n\n');
            end
            if 1 % all qMon
                allqMon = 1;
                fprintf(fid,'subject to qMon {c1_ind in 1..T-1, c2_ind in 1..T}:\n');
                fprintf(fid,'q[c1_ind+1,c2_ind] - q[c1_ind,c2_ind] <= 0;\n\n');
            end
            
            if 0 % qMon below diag only
                allqMon = 0;
                fprintf(fid,'subject to qMon {c1_ind in 1..T-1, c2_ind in 1..T : c1_ind >= c2_ind}:\n');
                fprintf(fid,'q[c1_ind+1,c2_ind] - q[c1_ind,c2_ind] <= 0;\n\n');
            end
            
            
        end
        fclose(fid);
        fprintf('\n ''%s'' (text file) written', modFileName)
        
    end
    if 1 % write AMPL's .DAT file
        datFileName = [thisLpName '.dat'];
        fid = fopen(datFileName, 'wt');
        if 1 % write parameters
            
            fprintf(fid,'param T = %d;\n\n', T);
            
            if 1 % w
                fprintf(fid,'param w : \n    ');
                for c_index = 1 : T % first row; column indices
                    fprintf(fid,'%d   ', c_index);
                end
                fprintf(fid,' :=\n');
                for c1_index = 1 : T % table of data values
                    fprintf(fid,'%d', c1_index); % 1st col <- row index
                    for c2_index = 1: T % fill values
                        fprintf(fid,'   %.9f', w(c1_index,c2_index));
                    end
                    fprintf(fid,'\n');
                end
                fprintf(fid,';\n\n');
            end
            
            if 1 % cost grid
                fprintf(fid,'param c = \r\n');
                fprintf(fid,'\t');
                for c_index = 1:T
                    fprintf(fid,'%d\t', c_index);
                    fprintf(fid,'%.9f\r\n\t', c(c_index));
                end
                fprintf(fid,';\r\n\r\n');
            end
            
            if 1 % fc
                fprintf(fid,'param fc : \n    ');
                for c_index = 1 : T % first row; column indices
                    fprintf(fid,'%d   ', c_index);
                end
                fprintf(fid,' :=\n');
                for c2_index = 1 : T % table of data values
                    fprintf(fid,'%d', c2_index); % 1st col <- row index
                    for c1_index = 1: T % fill values
                        fprintf(fid,'   %.9f', f_joint(c1_index,c2_index));
                    end
                    fprintf(fid,'\n');
                end
                fprintf(fid,';\n\n');
            end
            
        end
        fclose(fid);
        fprintf('\n ''%s'' (text file) written', datFileName)
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
        if 1 % write: display options
            fprintf(fid,'# --- Display options -----\n');
            fprintf(fid,'\n');
        end
        if 1 % write: Write out Numerical LP -> Numerical_LP.txt
            fprintf(fid,'# --- Write out Numerical LP -----\n');
            NumLPFileName = ['Numerical_' thisLpName '.txt'];
            fprintf(fid,'expand >> %s;\n',NumLPFileName);
            fprintf(fid,'\n');
        end
        if 1 % write: call Cplex
            fprintf(fid,'# --- call CPLEX ----\n');
            fprintf(fid,'option solver ''%s'';\n', [cplexPath 'cplexamp']);
            fprintf(fid,'solve;\n\n');
        end
        if 1 % write: Store LP Value and optimal solution in .txt files
            fprintf(fid,'# --- Store optimal solution in .txt files --- \n');
            fprintf(fid,'print{c1_ind in 1..T, c2_ind in 1..T}: q[c1_ind,c2_ind] > q_out.txt;\n');
            fprintf(fid,'close q_out.txt;\n\n');
            fprintf(fid,'print O_BUYER_SURPLUS > LP_Value_out.txt;\n');
            fprintf(fid,'close LP_Value_out.txt;');
        end
        
        if 1 % Load dual and slacks
            fprintf(fid,'print{c1_ind in 1..T, c2_ind in 1..T : c1_ind <= c2_ind}: DemandConstraint[c1_ind,c2_ind].dual > DemandConstraintDuals_out.txt;\n');
            fprintf(fid,'close DemandConstraintDuals_out.txt;\n\n');
            
            fprintf(fid,'print{c1_ind in 1..T, c2_ind in 1..T : c1_ind <= c2_ind}: DemandConstraint[c1_ind,c2_ind].slack > DemandConstraintslack_out.txt;\n');
            fprintf(fid,'close DemandConstraintslack_out.txt;\n\n');
            
            
            if allqMon
                fprintf(fid,'print{c1_ind in 1..T-1, c2_ind in 1..T}: qMon[c1_ind,c2_ind].dual > qMonDuals_out.txt;\n');
                fprintf(fid,'close qMonDuals_out.txt;\n\n');
                
                fprintf(fid,'print{c1_ind in 1..T-1, c2_ind in 1..T}: qMon[c1_ind,c2_ind].slack > qMonslack_out.txt;\n');
                fprintf(fid,'close qMonslack_out.txt;\n\n');
            else
                fprintf(fid,'print{c1_ind in 1..T-1, c2_ind in 1..T : c1_ind >= c2_ind}: qMon[c1_ind,c2_ind].dual > qMonDuals_out.txt;\n');
                fprintf(fid,'close qMonDuals_out.txt;\n\n');
                
                fprintf(fid,'print{c1_ind in 1..T-1, c2_ind in 1..T : c1_ind >= c2_ind}: qMon[c1_ind,c2_ind].slack > qMonslack_out.txt;\n');
                fprintf(fid,'close qMonslack_out.txt;\n\n');
            end
            
            fprintf(fid,'print{c2_ind in 1..T}: qNonNeg[c2_ind].dual > qNonNegDuals_out.txt;\n');
            fprintf(fid,'close qNonNegDuals_out.txt;\n\n');
            
            fprintf(fid,'print{c2_ind in 1..T}: qNonNeg[c2_ind].slack > qNonNegslack_out.txt;\n');
            fprintf(fid,'close qNonNegslack_out.txt;\n\n');
            
        end
        
        if 1 % write: Solution Report: _conname, _con.dual, _con.slack, _con.body, _con.ub, _con.lb
            fprintf(fid,'# --- Solution Report  --- \n');
            fprintf(fid,'display O_BUYER_SURPLUS > SOL_REPORT.txt;\n');
            fprintf(fid,'display _conname, _con.dual, _con.slack, _con.body, _con.ub, _con.lb  >> SOL_REPORT.txt;\r\n');
            fprintf(fid,'close SOL_REPORT.txt;\r\n\r\n');
        end
         
        if 1 % close .run file
            fclose(fid);
        end
        fprintf('\n ''%s'' (text file) written', runFileName)
    end
    if 1 % system call: feed .RUN file to AMPL
        fprintf('\n Solving the given LP %s with CPLEX,\n', thisLpName)
        %tic
        system([amplPath 'ampl ' runFileName]);
        %toc
        fprintf(' ... CPLEX is done\n\n')
    end
    if 1 % Load:  LP_Value, Q, M (function output)
        load LP_Value_out.txt;
        BSopt_LP_IICIIRQM = LP_Value_out;
        
        load q_out.txt;
        q = q_out;
        q=reshape(q,T,T);
        fprintf(' q loaded in Matlab\n') 
    end
    
    
    if 1 
        load DemandConstraintDuals_out.txt;
        Delta = DemandConstraintDuals_out;
        load DemandConstraintslack_out.txt;
        DeltaSlack = DemandConstraintslack_out;
        load qMonDuals_out.txt;
        Mu = qMonDuals_out;
        Mu=reshape(Mu,T-1,T);
        load qMonslack_out.txt;
        MuSlack = qMonslack_out;
        load qNonNegDuals_out.txt;
        NuT = qNonNegDuals_out;
        load qNonNegslack_out.txt;
        NuTSlack = qNonNegslack_out;
    end
end


%save([subFolderName '.mat']);
if 0 % final report
    fprintf(['\n Output saved in subfolder: ' subFolderName ])
    fprintf('\n^^^^^^^^^ %s is done ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ \n', thisFileName)
end

cd(Local)