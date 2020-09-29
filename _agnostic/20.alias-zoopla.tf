if [ -f "$HOME/development/devops/terraform/terraform" ]; then
    if ! type tfsso &>/dev/null; then
      printf "$(git archive --remote=ssh://git@gitlab.zoopla.co.uk/devops/terraform-wrapper.git HEAD install-sso | tar -xO)" |sed 1,1d \
        >> ~/.shellrc.d/_agnostic/19.alias.zoopla.tfsso
      chmod 0755 ~/.shellrc.d/_agnostic/19.alias.zoopla.tfsso
      source ~/.shellrc.d/_agnostic/19.alias.zoopla.tfsso
      declare -f tfsso
    fi

    # this is the most useful
    if [ -z "$USE_AWS_SSO" ]; then
        alias tf="$HOME/development/devops/terraform/terraform"
    else
        alias tf=tfsso
    fi

    # this is occasionally useful
    export TF_WRAPPER_SCRIPT="$HOME/development/devops/terraform/terraform"
fi
