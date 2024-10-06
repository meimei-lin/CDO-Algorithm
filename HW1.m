chromosome = input('輸入染色體序列:','s');
% 提示使用者輸入染色體序列，並存在變數chromosome中
head = strfind(chromosome, 'ATG');
% 查染色體序列中的起始字串'ATG'，並把結果存在head變數中
if ~isempty(head)
    % 如果head變數不為空
    tail = {'TAA', 'TAG', 'TGA'};
    % 定義三個終止字串，存在tail這個cell array中
    genes = {}; 
    % 用來存找到的基因序列
    for j = 1:length(head)
    % 遍歷所有的起始字串位置
        gene_found = false; 
        % 用來標記是否找到了基因，預設值為false
        for i = 1:length(tail)
        % 遍歷所有的終止字串
            stop = strfind(chromosome, tail{i});
            % 找到染色體序列有終止字串的位置，並存在stop變數中
            stop = stop(stop > head(j));
            % 確保終止字串在起始字串之後
            if ~isempty(stop)
            % 如果stop不為空，表示有起始字串和終止字串組成的序列
                gene = chromosome(head(j) + 3:stop(1) - 1);
                % 提取起始字串的下一個位置與終止字串的前一個位置所包含的基因序列
                if mod(length(gene), 3) == 0
                % 檢查gene的長度是否為三的倍數
                    gene_three = regexp(gene, '.{3}', 'match');
                    % 將gene以三個一組分組
                    if numel(gene_three) ~= 0 && mod(length(gene_three{1}), 3) == 0
                    % 如果基因序列不為空且是三的倍數
                        genes{end+1} = strjoin(gene_three, '');
                        gene_found = true;
                        break;
                    else
                        disp('no gene is found.');
                        break;
                        % 不符合條件，顯示沒找到基因
                    end
                else
                     disp('no gene is found.');
                     break;
                     % 不符合條件，顯示沒找到基因
                end
              end
            end
    end

    if ~gene_found
    % 如果沒有找到基因序列
        disp('no gene is found.');
        % 顯示沒找到基因
    end
    
    if ~isempty(genes)
        % 如果找到了基因
        disp('Output:');
        disp(genes);
        % 顯示基因序列
    else
        disp('no gene is found.');
    end
else
    disp('no gene is found.');
    % 沒有找到起始字串
end
