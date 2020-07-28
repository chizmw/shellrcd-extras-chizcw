if [ -f "$HOME/development/devops/terraform/terraform" ]; then
    # this is the most useful
    alias tf="$HOME/development/devops/terraform/terraform"

    # this is occasionally useful
    export TF_WRAPPER_SCRIPT="$HOME/development/devops/terraform/terraform"
fi
