#****************************************************************
#
#   brief:  批量删除github个人名下的项目
#   site:   http://www.phpcreeper.com
#   blog:   http://www.blogdaren.com
#   author: blogdaren<blogdaren@163.com>
#   modify: 2022.04.10
#
#****************************************************************


help(){
    echo ""
    echo "[脚本使用说明]"
    echo ""
    echo "1. 默认会自动创建config.ini，如果没有请手动创建, 总共只有两个配置选项：username 和 token";
    echo "2. 在config.ini中配置在GIHUB官网上的个人用户名,  即: USERNAME='在这里填写你自己的用户名'";
    echo "3. 在config.ini中配置在GIHUB官网上生成好的TOKEN, 即: TOKEN='在这里填写你自己的TOKEN'";
    echo "4. 默认会自动创建repos.txt，如果没有请手动创建, 文件名必须命名为: repos.txt, 用于配置待删项目";
    echo "5. 打开repos.txt文件新增待删项目，支持批量删除，所以一行一个, 格式形如：username/reponame";
    echo "6. 最后保存脚本，然后执行: sh BatchDeleteGithubRepos.sh [show|fetch|remove]";
    echo ""
}

show(){
    listReposToBeDeleted;
}

fetch(){
    if [ -z "$USERNAME" ]; then
        echo ""
        echo "[在线查询项目操作失败]"
        echo ""
        echo ">> 请在config.ini中配置有效的github用户名"
        echo ""
        exit
    fi

    echo ""
    echo "====================远程在线项目列表===================="
    echo ""
    api_data=`curl -s $USER_REPO_GITHUB_API`
    getJsonValuesByAwk "$api_data" "full_name" "none/none"
    echo ""
    echo "====================远程在线项目列表===================="
    echo ""
    echo ""
}

remove(){
    if [ -z "$TOKEN" ]; then
        echo ""
        echo "[批量删除操作失败]"
        echo ""
        echo '>> TOKEN无效: 发现TOKEN值为空，请提供有效TOKEN';
        echo '>> TOKEN生成：https://github.com/settings/tokens';
        echo '>> TOKEN权限: 生成TOKEN时必须勾选delete repo权限';
        echo '>> TOKEN设置: 在config.ini配置上面生成的TOKEN值';
        echo '>> TOKEN安全: 操作完毕后建议立即删除生成的TOKEN';
        echo ""
        exit
    fi

    if [ ! -f "./$TO_DELETE_REPOS_FILE" ]; then
        echo ""
        echo "[批量删除操作失败]"
        echo ""
        echo ">> 文件无效: 当前目录中找不到待删项目所在的文件名: repos.txt";
        echo ""
        exit
    fi

    listReposToBeDeleted;

    read -p ">> 确认要继续删除上述项目列表吗？【y/n】" answer

    if [ "$answer" != 'y' ];then
        echo ""
        echo "[批量删除操作失败]"
        echo ""
        echo ">> 你放弃了执行删除操作";
        echo ""
        exit
    fi

    while read repo;
    do 
        if [ ! -z "$repo" ]; then
            curl -XDELETE -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo ";
            #echo $repo
        fi
    done < $TO_DELETE_REPOS_FILE
}

listReposToBeDeleted(){
    echo ""
    echo "====================待删项目列表===================="
    echo ""
    cat $TO_DELETE_REPOS_FILE
    echo ""
    echo "====================待删项目列表===================="
    echo ""
}

###
### 方法简要说明：
###
### 1. 是先查找一个字符串：带双引号的key。如果没找到，则直接返回defaultValue。
### 2. 查找最近的冒号，找到后认为值的部分开始了，直到在层数上等于0时找到这3个字符：,}]。
### 3. 如果有多个同名key，则依次全部打印（不论层级，只按出现顺序）
###
### @author lux feary
###
### 3 params: json, key, defaultValue
function getJsonValuesByAwk() 
{
    awk -v json="$1" -v key="$2" -v defaultValue="$3" 'BEGIN{
        foundKeyCount = 0
        while (length(json) > 0) {
            # pos = index(json, "\""key"\""); ## 这行更快一些，但是如果有value是字符串，且刚好与要查找的key相同，会被误认为是key而导致值获取错误
            pos = match(json, "\""key"\"[ \\t]*?:[ \\t]*");
            if (pos == 0) {if (foundKeyCount == 0) {print defaultValue;} exit 0;}

            ++foundKeyCount;
            start = 0; stop = 0; layer = 0;
            for (i = pos + length(key) + 1; i <= length(json); ++i) {
                lastChar = substr(json, i - 1, 1)
                currChar = substr(json, i, 1)

                if (start <= 0) {
                    if (lastChar == ":") {
                        start = currChar == " " ? i + 1: i;
                        if (currChar == "{" || currChar == "[") {
                            layer = 1;
                        }
                    }
                } else {
                    if (currChar == "{" || currChar == "[") {
                        ++layer;
                    }
                    if (currChar == "}" || currChar == "]") {
                        --layer;
                    }
                    if ((currChar == "," || currChar == "}" || currChar == "]") && layer <= 0) {
                        stop = currChar == "," ? i : i + 1 + layer;
                        break;
                    }
                }
            }

            if (start <= 0 || stop <= 0 || start > length(json) || stop > length(json) || start >= stop) {
                if (foundKeyCount == 0) {print defaultValue;} exit 0;
            } else {
                print substr(json, start, stop - start);
            }

            json = substr(json, stop + 1, length(json) - stop)
        }
    }'
}

loadConfig(){
    if [ ! -f $CONFIG_FILE ];then
        touch $CONFIG_FILE
        echo "" > $CONFIG_FILE
        echo "#USERNAME代表github上的用户名"   >> $CONFIG_FILE
        echo "USERNAME=''"   >> $CONFIG_FILE
        echo "#TOKEN代表从github上获取的TOKEN" >> $CONFIG_FILE
        echo "TOKEN=''" >> $CONFIG_FILE
    fi

    if [ ! -f "./$TO_DELETE_REPOS_FILE" ]; then
        touch $TO_DELETE_REPOS_FILE
    fi

    source $CONFIG_FILE
}

#加载配置文件
CONFIG_FILE="./config.ini"
TO_DELETE_REPOS_FILE="repos.txt"
loadConfig;
USER_REPO_GITHUB_API="https://api.github.com/users/$USERNAME/repos"



case "$1" in
    show)
        $1
        ;;
    fetch)
        $1
        ;;
    remove)
        $1
        ;;
    *)
        echo ""
        echo "[脚本执行说明]"
        echo ""
        echo $"\$ sh $0 [show|fetch|remove]"
        echo ""
        echo "[可用命令说明]"
        echo ""
        echo "1. show:   查看本地自行配置好的待删公共项目"
        echo "2. fetch:  根据用户名在线查询名下的公共项目"
        echo "3. remove: 根据配置文件批量删除指定公共项目"
        help;
        exit 
esac
exit $?



