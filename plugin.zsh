favorite-directories:cd() {
    # eval prevents IFS to modify in global scope
    IFS=$'\n' eval 'local sources=($(favorite-directories:get))'

    local maxdepth
    local mindepth
    local dir

    echo $sources

    local target_dir=$({
        for source in "${sources[@]}"; do
            read -r dir maxdepth mindepth <<< "$source"

            find -L "$dir" \
                -maxdepth "${maxdepth:-1}" \
                -mindepth "${mindepth:-1}" \
                -type d
        done
    } | fzf-tmux)

    local token=${target_dir//:*/}
    local target_dir=${target_dir//*: /}

    for source in "${sources[@]}"; do
        read -r name maxdepth dir mindepth <<< "$source"

        if [ "$name" = "$token" ]; then
            eval cd "$dir/$target_dir"
            break
        fi
    done

    unset sources
    unset maxdepth
    unset dir
    unset target_dir
    unset token

    for func in "${precmd_functions[@]}"; do
        "$func"
    done

    zle reset-prompt
}

favorite-directories:get() {
    cat $FAV_DIRECTORIES_LIST_FILE
}

zle -N favorite-directories:cd
