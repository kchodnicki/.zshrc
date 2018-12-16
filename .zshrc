# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/chodnicki/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ll="ls -laG"
alias vimgo="vim -u ~/.vimrc.go"

# POWERLEVEL9k config
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator history)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
# Add a space in the first prompt
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

export GOPATH='/Users/chodnicki/go-workspace'
export GOBIN='/Users/chodnicki/go-workspace/bin'
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$GOBIN:$GOPATH

export KUBECONFIG=/Users/chodnicki/my_kubernetes/config-development
kubectl config set-cluster development --server=https://10.145.66.30:6443 --certificate-authority=/Users/chodnicki/my_kubernetes/ca.pem
kubectl config set-credentials developer --server=https://10.145.66.30:6443 --certificate-authority=/Users/chodnicki/my_kubernetes/ca.pem --client-key=/Users/chodnicki/my_kubernetes/admin-kubernetes-master-0-key.pem --client-certificate=/Users/chodnicki/my_kubernetes/admin-kubernetes-master-0.pem

export AWS_ACCESS_KEY_ID=AKIAILIL2AO3V4MSBIBQ
export AWS_SECRET_KEY=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

gwurl(){
    addr=$(cat f5go_config | grep server: | cut -d " " -f 2)
    r=$(curl curl --fail --silent -k --cacert ca.pem --key blue-admin-key.pem --cert blue-admin.pem https://"$addr"/"$1" )
    echo $r | jq
}

kubeaws()
{
    loc=$(pwd)
    mkdir ~/tmp
    addr=$(cat f5go_config | grep server: | cut -d " " -f 2)
    pushd ~/tmp
    scp -i "$loc"/secrets/*_rsa centos@$addr:/etc/kubernetes/ssl/kube-apiserver-key.pem .
    scp -i "$loc"/secrets/*_rsa centos@$addr:/etc/kubernetes/ssl/kube-apiserver.pem .
    scp -i "$loc"/secrets/*_rsa centos@$addr:/etc/blue/ssl/blue-user/blue-admin-key.pem "$loc"/blue-admin-key.pem
    scp -i "$loc"/secrets/*_rsa centos@$addr:/etc/blue/ssl/blue-user/blue-admin.pem "$loc"/blue-admin.pem
    scp -i "$loc"/secrets/*_rsa centos@$addr:/etc/blue/ssl/blue-user/ca.pem "$loc"/ca.pem
    touch kubeconfig-aws.yaml
    export KUBECONFIG=`pwd`/kubeconfig-aws.yaml
    kubectl config set-cluster aws-cluster --insecure-skip-tls-verify --server https://$addr:6443
    kubectl config set-credentials aws-cluster-admin --client-certificate kube-apiserver.pem --client-key kube-apiserver-key.pem
    kubectl config set-context aws --cluster aws-cluster --user aws-cluster-admin
    kubectl config use-context aws
    popd
}

kubeCft(){
    loc=$(pwd)
    mkdir ~/tmp >/dev/null 2>/dev/null
    addrraw=$1
    echo "Trying to resolve DNS: \033[0;32m$addrraw \033[0m"
    ipInRaw=`echo $addrraw | grep -ohE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`
    addr=`host $addrraw | grep -ohE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`
    if [[ -z "$addr" ]] || ! [[ -z "$ipInRaw" ]] ; then
       echo "Could not look up IP address for $addrraw. Trying it as address."
       addr=$1
    fi
    echo "IP: \033[0;32m$addr \033[0m"
    pushd ~/tmp >/dev/null 2>/dev/null
    scp centos@$addr:/etc/kubernetes/ssl/kube-apiserver-key.pem . >/dev/null 2>/dev/null || {echo "\033[0;31mCommand failed\033[0m at downloading kube-apiserver-key.pem"; return 1}
    scp centos@$addr:/etc/kubernetes/ssl/kube-apiserver.pem . >/dev/null 2>/dev/null || {echo "\033[0;31mCommand failed\033[0m at downloading kube-apiserver.pem"; return 1}
    scp centos@$addr:/etc/blue/ssl/blue-user/blue-admin-key.pem . >/dev/null 2>/dev/null || echo "\033[0;31mCommand failed\033[0m at downloading blue-admin-key.pem"
    scp centos@$addr:/etc/blue/ssl/blue-user/blue-admin.pem . >/dev/null 2>/dev/null || echo "\033[0;31mCommand failed\033[0m at downloading blue-admin.pem"
    scp centos@$addr:/etc/blue/ssl/blue-user/ca.pem . >/dev/null 2>/dev/null || echo "\033[0;31mCommand failed\033[0m at downloading ca.pem"
    touch kubeconfig-aws.yaml
    export KUBECONFIG=`pwd`/kubeconfig-aws.yaml
    kubectl config set-cluster aws-cluster --insecure-skip-tls-verify --server https://$addr:6443 >/dev/null
    kubectl config set-credentials aws-cluster-admin --client-certificate kube-apiserver.pem --client-key kube-apiserver-key.pem >/dev/null
    kubectl config set-context aws --cluster aws-cluster --user aws-cluster-admin >/dev/null
    kubectl config use-context aws >/dev/null
    popd >/dev/null 2>/dev/null
    cd $loc
    kubectl get namespace >/dev/null 2>/dev/null || {echo "Self check after the script \033[0;31mFAILED\033[0m (Could not get namespaces). Sorry :(" && return 1 }
    { kubectl cluster-info | grep $addr >/dev/null 2>/dev/null} || {echo "Self check after the script \033[0;31mFAILED\033[0m (Cluster set to wrong IP). Sorry :(" && return 1 }
    echo "\033[0;32mScript succeeded, cluster set to IP $addr\033[0m"
}


curlCftGw(){
    addr=$(kubectl cluster-info | grep master | grep -oh https://.\* | awk -v FS="(https://|:)" '{print $2}')
    r=$(curl -k --cacert ~/tmp/ca.pem --key ~/tmp/blue-admin-key.pem --cert ~/tmp/blue-admin.pem https://"$addr"/"$1" )
    echo $r
}

changeLogLevel(){
  port=$1
  capability=$2
  pod=$3
  level=$4
  API_VERSION_COMMON=v1alpha3
  command="kubectl exec -it $pod -- curl -s -k --key etc/blue/ssl/machine-svc-key --cert etc/blue/ssl/machine-svc-cert --resolve $service:$port:127.0.0.1 https://$capability:$port/$API_VERSION_COMMON/config"
  loggers=`eval $command`
  replacedLoggers=$(echo $loggers | sed -E "s/WARN|DEBUG|ERROR|INFO/$level/g")
  command2="curl -s -k --key etc/blue/ssl/machine-svc-key --cert etc/blue/ssl/machine-svc-cert -X PUT -H \"Content-Type: application/json\" --data '$replacedLoggers' --resolve $capability:$port:127.0.0.1 https://$capability:$port/$API_VERSION_COMMON/config"
  echo "\033[0;32mResult: \033[0m"
  eval "kubectl exec -it $pod -- $command2" | jq
}

getLogLevel(){
  port=$1
  capability=$2
  pod=$3
  API_VERSION_COMMON=v1alpha3
  command="kubectl exec -it $pod -- curl -s -k --key etc/blue/ssl/machine-svc-key --cert etc/blue/ssl/machine-svc-cert --resolve $capability:$port:127.0.0.1 https://$capability:$port/$API_VERSION_COMMON/config"
  loggers=`eval $command`
  echo $loggers | jq
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
